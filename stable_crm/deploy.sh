#!/bin/bash

# Скрипт развертывания CRM системы на VPS
# Домен: orehovyam.ru
# IP: 83.166.246.72

set -e

echo "🚀 Начинаем развертывание CRM системы на orehovyam.ru"

# Проверяем, что мы в правильной директории
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Ошибка: запустите скрипт из папки stable_crm"
    exit 1
fi

# Создаем папку для SSL сертификатов
echo "📁 Создаем папку для SSL сертификатов..."
mkdir -p ssl

# Проверяем наличие SSL сертификатов
if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
    echo "⚠️  Внимание: SSL сертификаты не найдены в папке ssl/"
    echo "   Для получения сертификатов выполните:"
    echo "   sudo certbot certonly --standalone -d orehovyam.ru"
    echo "   sudo cp /etc/letsencrypt/live/orehovyam.ru/fullchain.pem ./ssl/cert.pem"
    echo "   sudo cp /etc/letsencrypt/live/orehovyam.ru/privkey.pem ./ssl/key.pem"
    echo ""
    echo "   Или создайте самоподписанные сертификаты для тестирования:"
    echo "   openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes"
    echo ""
    read -p "Продолжить без SSL сертификатов? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Проверяем файл .env
if [ ! -f ".env" ]; then
    echo "📝 Создаем .env файл из env.production..."
    cp env.production .env
    echo "⚠️  Не забудьте настроить VK_ID_CLIENT_ID и VK_ID_CLIENT_SECRET в .env файле!"
fi

# Останавливаем существующие контейнеры
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose -f docker-compose.prod.yml down || true

# Собираем и запускаем приложение
echo "🔨 Собираем и запускаем приложение..."
docker-compose -f docker-compose.prod.yml up -d --build

# Ждем запуска
echo "⏳ Ждем запуска приложения..."
sleep 10

# Проверяем статус
echo "📊 Проверяем статус контейнеров..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "✅ Развертывание завершено!"
echo ""
echo "🌐 Ваше приложение должно быть доступно по адресу:"
echo "   https://orehovyam.ru"
echo ""
echo "📋 Для проверки логов используйте:"
echo "   docker-compose -f docker-compose.prod.yml logs -f app"
echo ""
echo "🔄 Для обновления приложения:"
echo "   ./deploy.sh"
echo ""
echo "⚠️  Не забудьте:"
echo "   1. Настроить VK ID приложение на id.vk.com"
echo "   2. Указать Redirect URI: https://orehovyam.ru/auth/callback"
echo "   3. Обновить .env файл с реальными VK ID данными"
