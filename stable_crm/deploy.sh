#!/bin/bash

# Скрипт деплоя CRM системы на VPS сервер
# Домен: orehovyam.ru

set -e

echo "🚀 Деплой CRM системы на VPS сервер"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Проверяем, что мы в правильной директории
if [ ! -f "docker-compose.prod.yml" ]; then
    error "Файл docker-compose.prod.yml не найден. Запустите скрипт из папки stable_crm"
fi

# Проверяем наличие .env файла
if [ ! -f ".env" ]; then
    log "Создаем .env файл из env.production..."
    cp env.production .env
    warning "Файл .env создан. Не забудьте настроить VK_ID_CLIENT_ID и VK_ID_CLIENT_SECRET!"
    warning "После настройки запустите скрипт снова."
    exit 1
fi

# Проверяем, что все необходимые переменные настроены
source .env

if [ "$VK_ID_CLIENT_ID" = "your_vk_id_client_id_here" ] || [ "$VK_ID_CLIENT_SECRET" = "your_vk_id_client_secret_here" ]; then
    error "VK ID настройки не настроены. Отредактируйте .env файл и запустите скрипт снова."
fi

if [ "$SECRET_KEY_BASE" = "WZv+aqEJcuptHW5NmGem0hNOTB/bIHJHXNir578hYW/Lnu66FXIs/96ccGF1OG86" ]; then
    warning "Используется стандартный SECRET_KEY_BASE. Рекомендуется сгенерировать новый для продакшена."
    read -p "Продолжить с текущим ключом? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Генерируем новый SECRET_KEY_BASE..."
        NEW_SECRET=$(mix phx.gen.secret)
        sed -i "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$NEW_SECRET/" .env
        log "Новый SECRET_KEY_BASE сгенерирован и сохранен в .env"
    fi
fi

# Останавливаем существующие контейнеры
log "Останавливаем существующие контейнеры..."
docker-compose -f docker-compose.prod.yml down --remove-orphans || true

# Удаляем старые образы для экономии места
log "Очищаем старые образы..."
docker image prune -f || true

# Собираем и запускаем приложение
log "Собираем и запускаем приложение..."
docker-compose -f docker-compose.prod.yml up -d --build

# Ждем запуска
log "Ждем запуска приложения..."
sleep 15

# Проверяем статус контейнеров
log "Проверяем статус контейнеров..."
docker-compose -f docker-compose.prod.yml ps

# Проверяем здоровье приложения
log "Проверяем здоровье приложения..."
for i in {1..10}; do
    if curl -f http://localhost:4000/health > /dev/null 2>&1; then
        log "Приложение успешно запущено и отвечает на запросы!"
        break
    else
        if [ $i -eq 10 ]; then
            error "Приложение не отвечает после 10 попыток. Проверьте логи: docker-compose -f docker-compose.prod.yml logs -f app"
        fi
        log "Попытка $i/10: приложение еще не готово, ждем..."
        sleep 5
    fi
done

# Проверяем базу данных
log "Проверяем подключение к базе данных..."
if docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U postgres > /dev/null 2>&1; then
    log "База данных работает корректно"
else
    warning "Проблемы с базой данных. Проверьте логи: docker-compose -f docker-compose.prod.yml logs postgres"
fi

# Проверяем SSL сертификаты
if [ -f "ssl/cert.pem" ] && [ -f "ssl/key.pem" ]; then
    log "SSL сертификаты найдены"
else
    warning "SSL сертификаты не найдены. Запустите setup-ssl.sh для настройки SSL"
fi

echo ""
log "✅ Деплой завершен успешно!"
echo ""
log "🌐 Ваше приложение доступно по адресу:"
echo "   https://$PHX_HOST (через Nginx)"
echo "   http://localhost:4000 (напрямую)"
echo ""
log "📋 Полезные команды:"
echo "   Просмотр логов: docker-compose -f docker-compose.prod.yml logs -f app"
echo "   Остановка: docker-compose -f docker-compose.prod.yml down"
echo "   Перезапуск: docker-compose -f docker-compose.prod.yml restart app"
echo ""
log "🔐 VK ID авторизация настроена для домена: $VK_ID_REDIRECT_URI"
echo ""
log "🎉 CRM система готова к использованию!"
