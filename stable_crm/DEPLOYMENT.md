# 🚀 Развертывание CRM системы на VPS

## Информация о сервере
- **IP адрес**: 83.166.246.72
- **Домен**: orehovyam.ru
- **Операционная система**: Ubuntu/Debian (рекомендуется)

## 📋 Предварительные требования

### 1. Подключение к серверу
```bash
ssh root@83.166.246.72
```

### 2. Обновление системы
```bash
apt update && apt upgrade -y
```

### 3. Установка Docker и Docker Compose
```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(unine -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Добавление пользователя в группу docker
usermod -aG docker $USER
```

### 4. Установка Git
```bash
apt install git -y
```

## 🌐 Настройка домена

### 1. Настройка DNS
Убедитесь, что в DNS настройках домена `orehovyam.ru` указан A-запись:
```
orehovyam.ru.    A    83.166.246.72
```

### 2. Проверка DNS
```bash
nslookup orehovyam.ru
```

## 🔐 Получение SSL сертификатов

### Способ 1: Let's Encrypt (рекомендуется)
```bash
# Установка certbot
apt install certbot -y

# Получение сертификата
certbot certonly --standalone -d orehovyam.ru

# Копирование сертификатов в проект
mkdir -p /root/stable_crm/ssl
cp /etc/letsencrypt/live/orehovyam.ru/fullchain.pem /root/stable_crm/ssl/cert.pem
cp /etc/letsencrypt/live/orehovyam.ru/privkey.pem /root/stable_crm/ssl/key.pem
```

### Способ 2: Самоподписанные сертификаты (для тестирования)
```bash
mkdir -p /root/stable_crm/ssl
cd /root/stable_crm/ssl

# Создание самоподписанного сертификата
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/C=RU/ST=Moscow/L=Moscow/O=OrehovYam/CN=orehovyam.ru"
```

## 📥 Развертывание приложения

### 1. Клонирование репозитория
```bash
cd /root
git clone https://github.com/BarkanovEugen/stableCrm.git
cd stableCrm/stable_crm
```

### 2. Настройка переменных окружения
```bash
# Копируем продакшн конфигурацию
cp env.production .env

# Редактируем .env файл
nano .env
```

**Важно**: Замените в `.env` файле:
- `your_vk_id_client_id_here` на реальный Client ID
- `your_vk_id_client_secret_here` на реальный Client Secret

### 3. Настройка VK ID приложения
1. Перейдите на [id.vk.com](https://id.vk.com)
2. Создайте новое приложение
3. Укажите Redirect URI: `https://orehovyam.ru/auth/callback`
4. Скопируйте Client ID и Client Secret в `.env` файл

### 4. Запуск развертывания
```bash
# Делаем скрипт исполняемым
chmod +x deploy.sh

# Запускаем развертывание
./deploy.sh
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

# Логи Nginx
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### 3. Проверка доступности
```bash
# Проверка HTTP (должен редиректить на HTTPS)
curl -I http://orehovyam.ru

# Проверка HTTPS
curl -I https://orehovyam.ru
```

## 🛠️ Управление приложением

### Остановка
```bash
docker-compose -f docker-compose.prod.yml down
```

### Запуск
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Перезапуск
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Обновление
```bash
cd /root/stableCrm/stable_crm
git pull origin main
./deploy.sh
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

### Автоматическое обновление SSL сертификатов
```bash
# Добавление в crontab
crontab -e

# Добавить строку (обновление каждые 60 дней)
0 0 1 */2 * certbot renew --quiet && cp /etc/letsencrypt/live/orehovyam.ru/fullchain.pem /root/stableCrm/stable_crm/ssl/cert.pem && cp /etc/letsencrypt/live/orehovyam.ru/privkey.pem /root/stableCrm/stable_crm/ssl/key.pem && docker-compose -f /root/stableCrm/stable_crm/docker-compose.prod.yml restart nginx
```

## 🚨 Устранение неполадок

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

### Проблема: SSL сертификаты не работают
```bash
# Проверка сертификатов
openssl x509 -in ssl/cert.pem -text -noout

# Проверка Nginx конфигурации
docker exec -it stable_crm_nginx nginx -t
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f`
2. Убедитесь, что все порты открыты
3. Проверьте настройки DNS
4. Обратитесь к документации Phoenix/Elixir

---

**Удачи с развертыванием! 🎉**
