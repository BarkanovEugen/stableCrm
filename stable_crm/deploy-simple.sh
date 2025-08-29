#!/bin/bash

# Упрощенный скрипт деплоя CRM системы на VPS сервер
# Домен: orehovyam.ru

echo "🚀 Упрощенный деплой CRM системы на VPS сервер"

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

# Останавливаем существующие контейнеры
log "Останавливаем существующие контейнеры..."
docker-compose -f docker-compose.prod.yml down --remove-orphans || true

# Собираем и запускаем приложение
log "Собираем и запускаем приложение..."
docker-compose -f docker-compose.prod.yml up -d --build

# Простое ожидание запуска
log "Ждем запуска приложения (30 секунд)..."
sleep 30

# Проверяем статус контейнеров
log "Проверяем статус контейнеров..."
docker-compose -f docker-compose.prod.yml ps

# Простая проверка доступности порта
log "Проверяем доступность порта 4000..."
if netstat -tlnp 2>/dev/null | grep -q ":4000 "; then
    log "Порт 4000 доступен"
else
    warning "Порт 4000 недоступен. Возможно, приложение еще запускается."
fi

# Проверяем SSL сертификаты
if [ -f "ssl/cert.pem" ] && [ -f "ssl/key.pem" ]; then
    log "SSL сертификаты найдены"
else
    warning "SSL сертификаты не найдены. Запустите setup-ssl.sh для настройки SSL"
fi

echo ""
log "✅ Упрощенный деплой завершен!"
echo ""
log "🌐 Ваше приложение должно быть доступно по адресу:"
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
log "🎉 CRM система запущена!"
echo ""
log "💡 Если приложение не отвечает, подождите еще несколько минут"
echo "   или проверьте логи: docker-compose -f docker-compose.prod.yml logs -f app"
