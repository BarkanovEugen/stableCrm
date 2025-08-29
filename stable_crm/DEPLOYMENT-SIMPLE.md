# 🚀 Простое развертывание CRM с VK ID

## 🎯 Что у нас есть:
✅ **SSL настроен** - https://orehovyam.ru работает  
✅ **Nginx настроен** - проксирует на порт 4000  
✅ **Простой Dockerfile** - без проблем с сетью  
✅ **Один docker-compose** - для всего  

## 📋 Быстрый запуск:

### 1. **Настройте VK ID приложение:**
- Перейдите на [id.vk.com](https://id.vk.com)
- Создайте приложение
- Укажите Redirect URI: `https://orehovyam.ru/auth/callback`
- Запишите Client ID и Client Secret

### 2. **Настройте переменные окружения:**
```bash
# Копируем конфигурацию
cp env.production .env

# Редактируем .env файл
nano .env
```

**Замените в .env файле:**
```bash
VK_ID_CLIENT_ID=ваш_реальный_client_id
VK_ID_CLIENT_SECRET=ваш_реальный_client_secret
VK_ID_REDIRECT_URI=https://orehovyam.ru/auth/callback
```

### 3. **Запустите CRM:**
```bash
# Делаем скрипт исполняемым
chmod +x start.sh

# Запускаем CRM
./start.sh
```

## 🔍 Проверка работы:

### Статус контейнеров:
```bash
docker-compose ps
```

### Логи приложения:
```bash
docker-compose logs -f app
```

### Доступность:
- **HTTPS**: https://orehovyam.ru
- **HTTP**: http://localhost:4000

## 🛠️ Управление:

### Остановка:
```bash
docker-compose down
```

### Запуск:
```bash
docker-compose up -d
```

### Обновление:
```bash
git pull origin main
./start.sh
```

## 🎉 Результат:
После успешного запуска у вас будет:
- ✅ Работающий CRM на https://orehovyam.ru
- ✅ Полноценная VK ID авторизация
- ✅ SSL сертификаты с автообновлением
- ✅ Nginx как обратный прокси

---

**Просто и надежно! 🚀**
