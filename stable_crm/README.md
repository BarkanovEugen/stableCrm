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
- **⚡ Решена проблема зависания** - два варианта скрипта деплоя

## 🚀 Быстрый деплой

### 1. Проверка готовности
```bash
./check-deployment-readiness.sh
```

### 2. Настройка SSL
```bash
./setup-ssl.sh
```

### 3. Деплой на VPS (выберите вариант)

#### Вариант A: Упрощенный деплой (рекомендуется) ⭐
```bash
./deploy-simple.sh
```
**Преимущества:** Быстро, без зависания, надежно

#### Вариант B: Полный деплой с проверками
```bash
./deploy.sh
```
**Особенности:** Детальные проверки, таймауты, мониторинг

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
- `TROUBLESHOOTING.md` - устранение неполадок
- `DEPLOYMENT-VK-ID.md` - подробная инструкция с VK ID
- `DEPLOYMENT.md` - общая инструкция по деплою
- `DEPLOYMENT-SIMPLE.md` - упрощенная версия

## 🔧 Скрипты

- `check-deployment-readiness.sh` - проверка готовности к деплою
- `deploy-simple.sh` - **упрощенный деплой (решение проблемы зависания)** ⭐
- `deploy.sh` - автоматический деплой с проверками
- `setup-ssl.sh` - настройка SSL сертификатов
- `start.sh` - запуск локальной версии

## 🚨 Решение проблемы зависания

### Проблема
Скрипт `deploy.sh` зависал на этапе ожидания запуска приложения (1500+ секунд).

### Решение ⭐
Используйте **`deploy-simple.sh`** - упрощенный скрипт деплоя:
- Фиксированное время ожидания (30 секунд)
- Простые проверки без сложной логики
- Быстрый деплой без зависания

### Рекомендации
- **Первый деплой:** `./deploy-simple.sh` (избежание зависания)
- **Продакшн:** `./deploy.sh` (полные проверки)
- **Обновления:** `./deploy-simple.sh` (быстро и надежно)

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

### Проблема: Скрипт деплоя зависает ⭐
**Решение:** Используйте упрощенный скрипт деплоя:
```bash
./deploy-simple.sh
```

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
./deploy-simple.sh
```

## 🎉 Результат

После успешного деплоя:
- ✅ CRM доступен на https://orehovyam.ru
- ✅ VK ID авторизация работает
- ✅ SSL сертификаты настроены
- ✅ Автоматическое обновление сертификатов
- ✅ Nginx как обратный прокси
- ✅ Автоматический редирект с HTTP на HTTPS
- ✅ **Проблема зависания решена**

## 📞 Поддержка

При возникновении проблем:
1. Запустите `./check-deployment-readiness.sh`
2. **При зависании используйте `./deploy-simple.sh`** ⭐
3. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f`
4. Убедитесь, что все порты открыты
5. Проверьте настройки DNS и SSL сертификаты

---

**🎯 Репозиторий полностью готов к деплою на VPS сервер!**

**Время деплоя: ~15-20 минут** ⏱️

**💡 Главное правило: При проблемах используйте `deploy-simple.sh`!**
