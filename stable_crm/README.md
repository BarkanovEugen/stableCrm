# CRM для Конюшни "Стабильная"

Веб-приложение для управления конюшней с авторизацией через VK ID и базовой CRM системой.

## Возможности

- 🏠 **Лендинг конюшни** - информация об услугах, отзывы, контакты
- 🔐 **Авторизация через VK ID** - безопасный вход через OAuth 2.0 с PKCE
- 👥 **Ролевая модель** - администраторы, менеджеры, клиенты, гости
- 📊 **CRM система** - управление пользователями и базовый функционал
- 🐳 **Docker развертывание** - простое развертывание на VPS

## Технологии

- **Backend**: Phoenix/Elixir
- **База данных**: PostgreSQL
- **Кэширование**: Redis
- **Frontend**: Phoenix LiveView + Tailwind CSS
- **Авторизация**: VK ID OAuth 2.0
- **Контейнеризация**: Docker + Docker Compose

## Быстрый старт

### Предварительные требования

- Docker и Docker Compose
- Elixir 1.18+ (для разработки)
- PostgreSQL (для разработки)

### Разработка

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd stable_crm
```

2. Установите зависимости:
```bash
mix deps.get
```

3. Запустите базу данных:
```bash
docker-compose up -d postgres
```

4. Создайте и настройте базу данных:
```bash
mix ecto.create
mix ecto.migrate
```

5. Запустите приложение:
```bash
mix phx.server
```

Приложение будет доступно по адресу: http://localhost:4000

### Продакшн развертывание

1. Создайте файл `.env` на основе `env.example`:
```bash
cp env.example .env
# Отредактируйте .env файл с вашими настройками
```

2. Сгенерируйте SECRET_KEY_BASE:
```bash
mix phx.gen.secret
```

3. Настройте VK ID приложение:
   - Создайте приложение на [id.vk.com](https://id.vk.com)
   - Получите Client ID и Client Secret
   - Укажите Redirect URI: `https://yourdomain.com/auth/callback`

4. Запустите приложение:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Структура проекта

```
stable_crm/
├── lib/
│   ├── stable_crm/           # Бизнес-логика
│   │   ├── accounts/         # Управление пользователями
│   │   └── vk_id_auth.ex    # VK ID интеграция
│   └── stable_crm_web/      # Web слой
│       ├── controllers/      # Контроллеры
│       ├── live/            # LiveView
│       └── components/      # Компоненты
├── priv/                    # Миграции и статика
├── assets/                  # CSS, JS, изображения
├── config/                  # Конфигурация
├── Dockerfile              # Docker образ
├── docker-compose.yml      # Разработка
└── docker-compose.prod.yml # Продакшн
```

## Конфигурация

### Переменные окружения

- `VK_ID_CLIENT_ID` - ID приложения VK ID
- `VK_ID_CLIENT_SECRET` - секрет приложения VK ID
- `VK_ID_REDIRECT_URI` - URI для callback после авторизации
- `SECRET_KEY_BASE` - секретный ключ Phoenix
- `PHX_HOST` - хост приложения
- `DATABASE_URL` - URL базы данных

### Роли пользователей

- **admin** - полный доступ к системе
- **manager** - управление клиентами и лошадьми
- **client** - доступ к своему профилю и лошадям
- **guest** - базовый доступ (по умолчанию)

## API Endpoints

### Авторизация
- `GET /auth/login` - инициация авторизации через VK ID
- `GET /auth/callback` - callback от VK ID
- `GET /auth/logout` - выход из системы

### CRM
- `GET /crm` - главная страница CRM
- `GET /crm/profile` - профиль пользователя

## Разработка

### Добавление новых функций

1. Создайте миграцию:
```bash
mix ecto.gen.migration create_new_table
```

2. Создайте схему в `lib/stable_crm/`

3. Создайте контекст в `lib/stable_crm/`

4. Создайте контроллер в `lib/stable_crm_web/controllers/`

5. Добавьте маршруты в `lib/stable_crm_web/router.ex`

### Тестирование

```bash
mix test
```

## Развертывание

### VPS с Docker

1. Установите Docker на VPS
2. Склонируйте репозиторий
3. Настройте `.env` файл
4. Запустите `docker-compose -f docker-compose.prod.yml up -d`

### SSL сертификаты

Для VK ID требуется HTTPS. Используйте Let's Encrypt:

```bash
# Установка certbot
sudo apt install certbot

# Получение сертификата
sudo certbot certonly --standalone -d yourdomain.com

# Копирование в проект
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
```

## Лицензия

MIT License

## Поддержка

По вопросам обращайтесь: support@stable.com
