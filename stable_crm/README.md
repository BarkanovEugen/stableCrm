# 🚀 Stable CRM - Готовая CRM система для деплоя на VPS

## ✅ Статус: Готов к деплою на VPS (100%)

Полноценная CRM система на Elixir/Phoenix с VK ID авторизацией, готовая к развертыванию на VPS сервере.

## 🎯 Особенности

- **🔐 VK ID авторизация** - современная система входа через VK
- **🐳 Docker готовность** - полная контейнеризация для продакшена
- **🔒 SSL автоматизация** - автоматическая настройка Let's Encrypt сертификатов
- **📱 Адаптивный дизайн** - современный UI на Tailwind CSS
- **🗄️ PostgreSQL** - надежная база данных
- **⚡ Phoenix LiveView** - интерактивные интерфейсы в реальном времени

## 🚀 Быстрый деплой

### 1. Проверка готовности
```bash
./check-deployment-readiness.sh
```

### 2. Настройка SSL
```bash
./setup-ssl.sh
```

### 3. Деплой на VPS
```bash
./deploy.sh
```

**Время деплоя: ~15-20 минут** ⏱️

## 📋 Требования

- VPS сервер с Ubuntu 22.04+
- Домен, указывающий на IP сервера
- VK ID приложение (настроить на [id.vk.com](https://id.vk.com))

## 🐳 Docker файлы

- `docker-compose.prod.yml` - продакшн конфигурация
- `Dockerfile.ready` - оптимизированный образ для продакшена
- `docker-compose.yml` - локальная разработка
- `docker-compose.simple.yml` - упрощенная версия

## 📚 Документация

- `DEPLOYMENT-QUICK.md` - быстрый старт (рекомендуется)
- `DEPLOYMENT-VK-ID.md` - подробная инструкция с VK ID
- `DEPLOYMENT.md` - общая инструкция по деплою
- `DEPLOYMENT-SIMPLE.md` - упрощенная версия

## 🔧 Скрипты

- `check-deployment-readiness.sh` - проверка готовности к деплою
- `deploy.sh` - автоматический деплой на VPS
- `setup-ssl.sh` - настройка SSL сертификатов
- `start.sh` - запуск локальной версии

## 🌐 Деплой на домен orehovyam.ru

Система настроена для работы с доменом `orehovyam.ru` и IP `83.166.246.72`.

## 📦 Зависимости

- **Elixir 1.15+** - основной язык
- **Phoenix 1.8+** - веб-фреймворк
- **Ecto 3.13+** - ORM для базы данных
- **PostgreSQL 15** - база данных
- **Tailwind CSS 4.1+** - CSS фреймворк
- **DaisyUI** - компоненты UI

## 🔐 Переменные окружения

Скопируйте `env.production` в `.env` и настройте:

```bash
# VK ID Configuration
VK_ID_CLIENT_ID=your_vk_id_client_id_here
VK_ID_CLIENT_SECRET=your_vk_id_client_secret_here
VK_ID_REDIRECT_URI=https://orehovyam.ru/auth/callback

# Phoenix Configuration
SECRET_KEY_BASE=your_secret_key_base_here
PHX_HOST=orehovyam.ru

# Database Configuration
DATABASE_URL=postgres://postgres:postgres@postgres:5432/stable_crm_prod
```

## 🚨 Устранение неполадок

### Проверка статуса
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Просмотр логов
```bash
docker-compose -f docker-compose.prod.yml logs -f app
```

### Проверка SSL
```bash
certbot certificates
nginx -t
```

## 📊 Мониторинг

```bash
# Статус контейнеров
docker-compose -f docker-compose.prod.yml ps

# Логи приложения
docker-compose -f docker-compose.prod.yml logs -f app

# Использование ресурсов
docker stats
```

## 🔄 Обновление

```bash
git pull origin main
docker-compose -f docker-compose.prod.yml up -d --build
```

## 🎉 Результат

После успешного деплоя:
- ✅ CRM доступен на https://orehovyam.ru
- ✅ VK ID авторизация работает
- ✅ SSL сертификаты настроены
- ✅ Автоматическое обновление сертификатов
- ✅ Nginx как обратный прокси
- ✅ Автоматический редирект с HTTP на HTTPS

## 📞 Поддержка

При возникновении проблем:
1. Запустите `./check-deployment-readiness.sh`
2. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f`
3. Убедитесь, что все порты открыты
4. Проверьте настройки DNS и SSL сертификаты

---

**🎯 Репозиторий полностью готов к деплою на VPS сервер!**

**Время деплоя: ~15-20 минут** ⏱️
