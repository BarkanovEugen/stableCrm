# 🚀 Развертывание CRM с VK ID авторизацией

## 🎯 Цель
Полноценная CRM система с работающей VK ID авторизацией на домене orehovyam.ru

## 📋 Предварительные требования

### 1. DNS настройки
Убедитесь, что домен `orehovyam.ru` указывает на IP `83.166.246.72`:
```
orehovyam.ru.    A    83.166.246.72
```

### 2. VK ID приложение
1. Перейдите на [id.vk.com](https://id.vk.com)
2. Создайте новое приложение
3. Укажите Redirect URI: `https://orehovyam.ru/auth/callback`
4. Запишите Client ID и Client Secret

## 🚀 Пошаговое развертывание

### Шаг 1: Подключение к серверу
```bash
ssh root@83.166.246.72
```

### Шаг 2: Установка Docker
```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Перезагрузка для применения изменений
reboot
```

### Шаг 3: Повторное подключение и клонирование
```bash
ssh root@83.166.246.72
cd /root
git clone https://github.com/BarkanovEugen/stableCrm.git
cd stableCrm/stable_crm
```

### Шаг 4: Настройка SSL сертификатов
```bash
# Делаем скрипт исполняемым
chmod +x setup-ssl.sh

# Запускаем настройку SSL
./setup-ssl.sh
```

**Важно**: Скрипт автоматически:
- Установит Nginx и Certbot
- Получит SSL сертификат от Let's Encrypt
- Настроит Nginx для проксирования на порт 4000
- Настроит автообновление сертификатов

### Шаг 5: Настройка переменных окружения
```bash
# Копируем продакшн конфигурацию
cp env.production .env

# Редактируем .env файл
nano .env
```

**Замените в .env файле**:
```bash
VK_ID_CLIENT_ID=ваш_реальный_client_id
VK_ID_CLIENT_SECRET=ваш_реальный_client_secret
VK_ID_REDIRECT_URI=https://orehovyam.ru/auth/callback
```

### Шаг 6: Запуск CRM приложения
```bash
# Запускаем приложение
docker-compose -f docker-compose.prod.yml up -d --build
```

## 🔍 Проверка работы

### 1. Проверка контейнеров
```bash
docker-compose -f docker-compose.prod.yml ps
```

### 2. Проверка логов
```bash
# Логи приложения
docker-compose -f docker-compose.prod.yml logs -f app

# Логи базы данных
docker-compose -f docker-compose.prod.yml logs -f postgres
```

### 3. Проверка доступности
```bash
# Проверка HTTP (должен редиректить на HTTPS)
curl -I http://orehovyam.ru

# Проверка HTTPS
curl -I https://orehovyam.ru
```

### 4. Тестирование VK ID авторизации
1. Откройте https://orehovyam.ru
2. Нажмите "Login via VK ID"
3. Пройдите авторизацию в VK
4. Должны попасть в CRM

## 🛠️ Управление приложением

### Остановка
```bash
docker-compose -f docker-compose.prod.yml down
```

### Запуск
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Обновление
```bash
cd /root/stableCrm/stable_crm
git pull origin main
docker-compose -f docker-compose.prod.yml up -d --build
```

## 🔐 SSL сертификаты

### Автообновление
Сертификаты автоматически обновляются каждый день в 12:00

### Ручное обновление
```bash
certbot renew
systemctl reload nginx
```

### Проверка статуса
```bash
certbot certificates
```

## 🚨 Устранение неполадок

### Проблема: VK ID авторизация не работает
1. Проверьте SSL сертификаты: `certbot certificates`
2. Убедитесь, что домен доступен по HTTPS
3. Проверьте Redirect URI в VK ID приложении
4. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f app`

### Проблема: Приложение не запускается
```bash
# Проверка логов
docker-compose -f docker-compose.prod.yml logs app

# Проверка портов
netstat -tlnp | grep :4000
```

### Проблема: База данных не подключается
```bash
# Проверка статуса PostgreSQL
docker-compose -f docker-compose.prod.yml logs postgres

# Проверка подключения
docker exec -it stable_crm_postgres_prod psql -U postgres -d stable_crm_prod
```

## 📊 Мониторинг

### Проверка ресурсов
```bash
# Использование диска
df -h

# Использование памяти
free -h

# Использование CPU
htop

# Логи Docker
docker system df
```

### Проверка Nginx
```bash
# Статус Nginx
systemctl status nginx

# Проверка конфигурации
nginx -t

# Логи Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 🎉 Результат

После успешного развертывания у вас будет:
- ✅ Работающий CRM на https://orehovyam.ru
- ✅ Полноценная VK ID авторизация
- ✅ SSL сертификаты с автообновлением
- ✅ Nginx как обратный прокси
- ✅ Автоматический редирект с HTTP на HTTPS

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f`
2. Убедитесь, что все порты открыты
3. Проверьте настройки DNS
4. Проверьте SSL сертификаты: `certbot certificates`

---

**Удачи с развертыванием! 🎉**
