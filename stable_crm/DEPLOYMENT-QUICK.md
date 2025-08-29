# 🚀 Быстрый деплой CRM на VPS

## ✅ Готовность к деплою: 100%

Репозиторий полностью готов к деплою на VPS сервер!

## 🎯 Быстрый старт

### 1. Подключение к VPS
```bash
ssh root@83.166.246.72
```

### 2. Установка Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
reboot
```

### 3. Клонирование и настройка
```bash
ssh root@83.166.246.72
cd /root
git clone https://github.com/BarkanovEugen/stableCrm.git
cd stableCrm/stable_crm
```

### 4. Настройка SSL (автоматически)
```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

### 5. Настройка переменных
```bash
cp env.production .env
nano .env
# Замените VK_ID_CLIENT_ID и VK_ID_CLIENT_SECRET на реальные значения
```

### 6. Деплой (выберите один из вариантов)

#### Вариант A: Полный деплой с проверками
```bash
chmod +x deploy.sh
./deploy.sh
```

#### Вариант B: Упрощенный деплой (рекомендуется при проблемах)
```bash
chmod +x deploy-simple.sh
./deploy-simple.sh
```

## 🔐 VK ID настройка

1. Перейдите на [id.vk.com](https://id.vk.com)
2. Создайте новое приложение
3. Укажите Redirect URI: `https://orehovyam.ru/auth/callback`
4. Скопируйте Client ID и Client Secret в `.env` файл

## 📋 Проверка готовности

Запустите скрипт проверки:
```bash
./check-deployment-readiness.sh
```

## 🚨 Устранение неполадок

### Проблема: Скрипт деплоя зависает
**Решение:** Используйте упрощенный скрипт деплоя:
```bash
./deploy-simple.sh
```

### Проблема: Приложение не запускается
```bash
docker-compose -f docker-compose.prod.yml logs -f app
```

### Проблема: База данных не подключается
```bash
docker-compose -f docker-compose.prod.yml logs postgres
```

### Проблема: SSL сертификаты
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

## 🎉 Результат

После успешного деплоя:
- ✅ CRM доступен на https://orehovyam.ru
- ✅ VK ID авторизация работает
- ✅ SSL сертификаты настроены
- ✅ Автоматическое обновление сертификатов

## 💡 Рекомендации

- **При первом деплое** используйте `deploy-simple.sh` для избежания зависания
- **Для продакшена** используйте `deploy.sh` с полными проверками
- **При проблемах** всегда проверяйте логи контейнеров
- **Для обновления** используйте `git pull` + `./deploy-simple.sh`

---

**Время деплоя: ~15-20 минут** ⏱️
