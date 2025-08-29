# 🚨 Устранение неполадок при деплое

## ⚠️ Проблема: Скрипт деплоя зависает

### Описание проблемы
Скрипт `deploy.sh` зависает на этапе ожидания запуска приложения (1500+ секунд).

### Причины
- Сложные проверки здоровья приложения
- Отсутствие таймаутов
- Проблемы с сетевыми проверками
- Долгая компиляция Elixir приложения

### Решение 1: Использовать упрощенный скрипт ⭐ РЕКОМЕНДУЕТСЯ
```bash
./deploy-simple.sh
```

**Преимущества:**
- Фиксированное время ожидания (30 секунд)
- Простые проверки без сложной логики
- Быстрый деплой без зависания

### Решение 2: Использовать обновленный основной скрипт
```bash
./deploy.sh
```

**Улучшения:**
- Таймаут запуска контейнеров: 5 минут
- Таймаут проверки здоровья: 3 минуты
- Пошаговые проверки с прогресс-баром

## 🔧 Другие проблемы и решения

### Проблема: Приложение не запускается
```bash
# Проверка статуса контейнеров
docker-compose -f docker-compose.prod.yml ps

# Просмотр логов приложения
docker-compose -f docker-compose.prod.yml logs -f app

# Проверка использования ресурсов
docker stats
```

### Проблема: База данных не подключается
```bash
# Проверка статуса PostgreSQL
docker-compose -f docker-compose.prod.yml logs postgres

# Проверка подключения к БД
docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U postgres

# Проверка переменных окружения
echo $DATABASE_URL
```

### Проблема: SSL сертификаты не работают
```bash
# Проверка сертификатов
certbot certificates

# Проверка конфигурации Nginx
nginx -t

# Перезапуск Nginx
systemctl reload nginx
```

### Проблема: VK ID авторизация не работает
```bash
# Проверка переменных окружения
echo $VK_ID_CLIENT_ID
echo $VK_ID_CLIENT_SECRET
echo $VK_ID_REDIRECT_URI

# Проверка доступности домена
curl -I https://orehovyam.ru
```

## 📋 Пошаговое устранение проблем

### Шаг 1: Проверка готовности
```bash
./check-deployment-readiness.sh
```

### Шаг 2: Проверка контейнеров
```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

### Шаг 3: Перезапуск при необходимости
```bash
# Остановка
docker-compose -f docker-compose.prod.yml down

# Очистка
docker system prune -f

# Перезапуск
./deploy-simple.sh
```

### Шаг 4: Проверка логов
```bash
# Логи приложения
docker-compose -f docker-compose.prod.yml logs -f app

# Логи базы данных
docker-compose -f docker-compose.prod.yml logs -f postgres

# Логи Nginx
tail -f /var/log/nginx/error.log
```

## 🚀 Рекомендации по деплою

### Для первого деплоя
```bash
./deploy-simple.sh
```
- Быстро и надежно
- Нет риска зависания
- Простые проверки

### Для продакшна
```bash
./deploy.sh
```
- Полные проверки здоровья
- Детальный мониторинг
- Таймауты для предотвращения зависания

### Для обновлений
```bash
git pull origin main
./deploy-simple.sh
```
- Быстрое обновление
- Минимальные проверки
- Стабильная работа

## 📊 Мониторинг и диагностика

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

### Проверка сети
```bash
# Открытые порты
netstat -tlnp

# Проверка доступности
curl -I http://localhost:4000
curl -I https://orehovyam.ru
```

### Проверка SSL
```bash
# Статус сертификатов
certbot certificates

# Проверка конфигурации
nginx -t

# Автообновление
certbot renew --dry-run
```

## 🎯 Часто задаваемые вопросы

### Q: Почему зависает основной скрипт?
A: Сложные проверки здоровья приложения могут занимать много времени. Используйте `deploy-simple.sh`.

### Q: Сколько времени должен занимать деплой?
A: Обычно 15-20 минут. Если больше - используйте упрощенный скрипт.

### Q: Что делать, если приложение не отвечает?
A: Проверьте логи контейнеров и убедитесь, что все переменные окружения настроены.

### Q: Как обновить приложение?
A: `git pull origin main && ./deploy-simple.sh`

## 📞 Поддержка

При возникновении проблем:
1. Запустите `./check-deployment-readiness.sh`
2. Проверьте логи: `docker-compose -f docker-compose.prod.yml logs -f`
3. Убедитесь, что все порты открыты
4. Проверьте настройки DNS и SSL сертификаты

---

**💡 Главное правило: При проблемах используйте `deploy-simple.sh`!**
