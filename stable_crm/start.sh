#!/bin/bash

# Скрипт запуска CRM системы
# Домен: orehovyam.ru

set -e

echo "🚀 Запуск CRM системы на orehovyam.ru"

# Проверяем, что мы в правильной директории
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Ошибка: запустите скрипт из папки stable_crm"
    exit 1
fi

# Проверяем файл .env
if [ ! -f ".env" ]; then
    echo "📝 Создаем .env файл из env.production..."
    cp env.production .env
    echo "⚠️  Не забудьте настроить VK_ID_CLIENT_ID и VK_ID_CLIENT_SECRET в .env файле!"
fi

# Останавливаем существующие контейнеры
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose down || true

# Собираем и запускаем приложение
echo "🔨 Собираем и запускаем приложение..."
docker-compose up -d --build

# Ждем запуска
echo "⏳ Ждем запуска приложения..."
sleep 10

# Проверяем статус
echo "📊 Проверяем статус контейнеров..."
docker-compose ps

echo ""
echo "✅ CRM система запущена!"
echo ""
echo "🌐 Ваше приложение доступно по адресу:"
echo "   https://orehovyam.ru (через Nginx)"
echo "   http://localhost:4000 (напрямую)"
echo ""
echo "📋 Для проверки логов используйте:"
echo "   docker-compose logs -f app"
echo ""
echo "🔄 Для обновления приложения:"
echo "   ./start.sh"
echo ""
echo "⚠️  Не забудьте:"
echo "   1. Настроить VK ID приложение на id.vk.com"
echo "   2. Указать Redirect URI: https://orehovyam.ru/auth/callback"
echo "   3. Обновить .env файл с реальными VK ID данными"
