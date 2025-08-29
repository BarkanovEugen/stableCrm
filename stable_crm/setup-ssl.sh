#!/bin/bash

# Скрипт настройки SSL для Ubuntu 22.04
# Домен: orehovyam.ru

set -e

echo "🔐 Настройка SSL сертификатов для orehovyam.ru"

# Проверяем, что мы root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите скрипт от имени root: sudo ./setup-ssl.sh"
    exit 1
fi

# Обновляем систему
echo "📦 Обновляем систему..."
apt update && apt upgrade -y

# Устанавливаем необходимые пакеты
echo "🔧 Устанавливаем необходимые пакеты..."
apt install -y certbot nginx

# Создаем папку для SSL
echo "📁 Создаем папку для SSL сертификатов..."
mkdir -p ssl

# Проверяем, доступен ли домен
echo "🌐 Проверяем доступность домена orehovyam.ru..."
if ! nslookup orehovyam.ru > /dev/null 2>&1; then
    echo "❌ Ошибка: домен orehovyam.ru недоступен"
    echo "   Проверьте DNS настройки домена"
    exit 1
fi

echo "✅ Домен доступен"

# Создаем временный Nginx конфиг для получения сертификата
echo "📝 Создаем временный Nginx конфиг..."
cat > /etc/nginx/sites-available/temp << 'EOF'
server {
    listen 80;
    server_name orehovyam.ru;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}
EOF

# Активируем временный сайт
ln -sf /etc/nginx/sites-available/temp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию Nginx
nginx -t

# Перезапускаем Nginx
systemctl restart nginx

# Получаем SSL сертификат
echo "🔐 Получаем SSL сертификат от Let's Encrypt..."
certbot certonly --webroot -w /var/www/html -d orehovyam.ru --non-interactive --agree-tos --email admin@orehovyam.ru

# Копируем сертификаты в проект
echo "📋 Копируем сертификаты в проект..."
cp /etc/letsencrypt/live/orehovyam.ru/fullchain.pem ./ssl/cert.pem
cp /etc/letsencrypt/live/orehovyam.ru/privkey.pem ./ssl/key.pem

# Устанавливаем правильные права
chown root:root ssl/cert.pem ssl/key.pem
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem

# Удаляем временный Nginx конфиг
echo "🧹 Удаляем временный Nginx конфиг..."
rm -f /etc/nginx/sites-enabled/temp
rm -f /etc/nginx/sites-available/temp

# Создаем основной Nginx конфиг для CRM
echo "📝 Создаем основной Nginx конфиг..."
cat > /etc/nginx/sites-available/orehovyam << 'EOF'
server {
    listen 80;
    server_name orehovyam.ru;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name orehovyam.ru;
    
    ssl_certificate /etc/letsencrypt/live/orehovyam.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/orehovyam.ru/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    
    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Активируем основной сайт
ln -sf /etc/nginx/sites-available/orehovyam /etc/nginx/sites-enabled/

# Проверяем конфигурацию
nginx -t

# Перезапускаем Nginx
systemctl restart nginx

# Настраиваем автообновление сертификатов
echo "🔄 Настраиваем автообновление сертификатов..."
cat > /etc/cron.d/ssl-renew << 'EOF'
0 12 * * * root certbot renew --quiet && systemctl reload nginx
EOF

echo ""
echo "✅ SSL настройка завершена!"
echo ""
echo "🌐 Ваш сайт доступен по адресу: https://orehovyam.ru"
echo ""
echo "📋 Сертификаты автоматически обновляются каждый день в 12:00"
echo ""
echo "🚀 Теперь можно запускать CRM приложение!"
echo "   docker-compose -f docker-compose.prod.yml up -d --build"
