# Используем официальный образ Elixir
FROM elixir:1.18-alpine AS builder

# Устанавливаем необходимые зависимости
RUN apk add --no-cache build-base git nodejs npm

# Устанавливаем hex и rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Создаем рабочую директорию
WORKDIR /app

# Копируем файлы зависимостей
COPY mix.exs mix.lock ./
COPY config config

# Устанавливаем зависимости
RUN mix deps.get --only prod
RUN mix deps.compile

# Копируем исходный код
COPY lib lib
COPY priv priv
COPY assets assets

# Компилируем приложение
RUN mix compile
RUN mix assets.deploy

# Создаем релиз
RUN mix release

# Создаем финальный образ
FROM alpine:3.19

# Устанавливаем необходимые зависимости
RUN apk add --no-cache openssl ncurses-libs libstdc++

# Создаем пользователя для приложения
RUN adduser -D -s /bin/sh app

# Создаем рабочую директорию
WORKDIR /app

# Копируем релиз из builder образа
COPY --from=builder /app/_build/prod/rel/stable_crm ./

# Меняем владельца файлов
RUN chown -R app:app /app

# Переключаемся на пользователя app
USER app

# Открываем порт
EXPOSE 4000

# Запускаем приложение
CMD ["bin/stable_crm", "start"]
