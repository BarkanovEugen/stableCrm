#!/bin/bash

# Скрипт проверки готовности репозитория к деплою на VPS
# Домен: orehovyam.ru

echo "🔍 Проверка готовности репозитория к деплою на VPS"
echo "=================================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Счетчики
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Функции для вывода
pass() {
    echo -e "${GREEN}✅ PASS${NC} $1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

fail() {
    echo -e "${RED}❌ FAIL${NC} $1"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

warn() {
    echo -e "${YELLOW}⚠️  WARN${NC} $1"
    WARNINGS=$((WARNINGS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

info() {
    echo -e "${BLUE}ℹ️  INFO${NC} $1"
}

echo ""

# 1. Проверка структуры проекта
echo "📁 Проверка структуры проекта..."
if [ -f "mix.exs" ]; then
    pass "mix.exs найден"
else
    fail "mix.exs не найден"
fi

if [ -f "mix.lock" ]; then
    pass "mix.lock найден"
else
    fail "mix.lock не найден"
fi

if [ -d "config" ]; then
    pass "Папка config найдена"
else
    fail "Папка config не найдена"
fi

if [ -d "lib" ]; then
    pass "Папка lib найдена"
else
    fail "Папка lib не найдена"
fi

# 2. Проверка конфигурации
echo ""
echo "⚙️  Проверка конфигурации..."
if [ -f "config/prod.exs" ]; then
    pass "config/prod.exs найден"
else
    fail "config/prod.exs не найден"
fi

if [ -f "config/runtime.exs" ]; then
    pass "config/runtime.exs найден"
else
    fail "config/runtime.exs не найден"
fi

if [ -f "config/config.exs" ]; then
    pass "config/config.exs найден"
else
    fail "config/config.exs не найден"
fi

# 3. Проверка Docker файлов
echo ""
echo "🐳 Проверка Docker файлов..."
if [ -f "docker-compose.prod.yml" ]; then
    pass "docker-compose.prod.yml найден"
else
    fail "docker-compose.prod.yml не найден"
fi

if [ -f "Dockerfile.ready" ]; then
    pass "Dockerfile.ready найден"
else
    fail "Dockerfile.ready не найден"
fi

# 4. Проверка переменных окружения
echo ""
echo "🔐 Проверка переменных окружения..."
if [ -f "env.production" ]; then
    pass "env.production найден"
else
    fail "env.production не найден"
fi

if [ -f "env.example" ]; then
    pass "env.example найден"
else
    fail "env.example не найден"
fi

# 5. Проверка скриптов
echo ""
echo "📜 Проверка скриптов..."
if [ -f "deploy.sh" ]; then
    pass "deploy.sh найден"
    if [ -x "deploy.sh" ]; then
        pass "deploy.sh исполняемый"
    else
        warn "deploy.sh не исполняемый (chmod +x deploy.sh)"
    fi
else
    fail "deploy.sh не найден"
fi

if [ -f "setup-ssl.sh" ]; then
    pass "setup-ssl.sh найден"
    if [ -x "setup-ssl.sh" ]; then
        pass "setup-ssl.sh исполняемый"
    else
        warn "setup-ssl.sh не исполняемый (chmod +x setup-ssl.sh)"
    fi
else
    fail "setup-ssl.sh не найден"
fi

# 6. Проверка документации
echo ""
echo "📚 Проверка документации..."
if [ -f "DEPLOYMENT-VK-ID.md" ]; then
    pass "DEPLOYMENT-VK-ID.md найден"
else
    fail "DEPLOYMENT-VK-ID.md не найден"
fi

if [ -f "README.md" ]; then
    pass "README.md найден"
else
    fail "README.md не найден"
fi

# 7. Проверка зависимостей
echo ""
echo "📦 Проверка зависимостей..."
if [ -f "mix.lock" ]; then
    if grep -q "phoenix" mix.lock; then
        pass "Phoenix зависимость найдена"
    else
        fail "Phoenix зависимость не найдена"
    fi
    
    if grep -q "ecto" mix.lock; then
        pass "Ecto зависимость найдена"
    else
        fail "Ecto зависимость не найдена"
    fi
    
    if grep -q "postgrex" mix.lock; then
        pass "PostgreSQL драйвер найден"
    else
        fail "PostgreSQL драйвер не найден"
    fi
fi

# 8. Проверка ассетов
echo ""
echo "🎨 Проверка ассетов..."
if [ -d "assets" ]; then
    pass "Папка assets найдена"
    if [ -f "assets/css/app.css" ]; then
        pass "app.css найден"
    else
        warn "app.css не найден"
    fi
    
    if [ -f "assets/js/app.js" ]; then
        pass "app.js найден"
    else
        warn "app.js не найден"
    fi
else
    fail "Папка assets не найдена"
fi

# 9. Проверка приватных файлов
echo ""
echo "🔒 Проверка приватных файлов..."
if [ -d "priv" ]; then
    pass "Папка priv найдена"
    if [ -d "priv/repo" ]; then
        pass "Папка priv/repo найдена"
    else
        warn "Папка priv/repo не найдена"
    fi
else
    fail "Папка priv не найдена"
fi

# 10. Проверка .gitignore
echo ""
echo "🚫 Проверка .gitignore..."
if [ -f ".gitignore" ]; then
    pass ".gitignore найден"
    if grep -q "_build" .gitignore; then
        pass "_build в .gitignore"
    else
        warn "_build не в .gitignore"
    fi
    
    if grep -q "deps" .gitignore; then
        pass "deps в .gitignore"
    else
        warn "deps не в .gitignore"
    fi
else
    fail ".gitignore не найден"
fi

# Итоговая статистика
echo ""
echo "=================================================="
echo "📊 ИТОГОВАЯ СТАТИСТИКА:"
echo "=================================================="
echo -e "Всего проверок: ${BLUE}$TOTAL_CHECKS${NC}"
echo -e "Успешно: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Провалено: ${RED}$FAILED_CHECKS${NC}"
echo -e "Предупреждения: ${YELLOW}$WARNINGS${NC}"

echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 Репозиторий полностью готов к деплою!${NC}"
    else
        echo -e "${GREEN}✅ Репозиторий готов к деплою с предупреждениями${NC}"
        echo -e "${YELLOW}Рекомендуется исправить предупреждения перед деплоем${NC}"
    fi
else
    echo -e "${RED}❌ Репозиторий НЕ готов к деплою${NC}"
    echo -e "${RED}Исправьте ошибки перед продолжением${NC}"
fi

echo ""

# Рекомендации
if [ $FAILED_CHECKS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    echo "🔧 РЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ:"
    echo ""
    
    if [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "${RED}Критические ошибки (исправьте обязательно):${NC}"
        echo "1. Убедитесь, что все необходимые файлы присутствуют"
        echo "2. Проверьте структуру проекта"
        echo "3. Убедитесь, что конфигурация корректна"
        echo ""
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Предупреждения (рекомендуется исправить):${NC}"
        echo "1. Сделайте скрипты исполняемыми: chmod +x *.sh"
        echo "2. Проверьте настройки .gitignore"
        echo "3. Убедитесь, что все ассеты на месте"
        echo ""
    fi
fi

echo "🚀 Следующие шаги:"
echo "1. Настройте VK ID приложение на https://id.vk.com"
echo "2. Обновите .env файл с реальными данными"
echo "3. Запустите setup-ssl.sh для настройки SSL"
echo "4. Запустите deploy.sh для деплоя"

# Возвращаем код выхода
if [ $FAILED_CHECKS -eq 0 ]; then
    exit 0
else
    exit 1
fi
