# Multi-stage build for production
FROM ubuntu:22.04 as builder

# Устанавливаем Elixir и зависимости
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    nodejs \
    npm \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Erlang и Elixir
RUN curl -fsSL https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb -o erlang-solutions_2.0_all.deb
RUN dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update && apt-get install -y esl-erlang elixir

# Set working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# Copy priv directory
COPY priv priv

# Copy config
COPY config config

# Copy lib
COPY lib lib

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix do compile, release

# Start a new build stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    libstdc++6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -u 1000 app

# Set working directory
WORKDIR /app

# Copy release from builder stage
COPY --from=builder --chown=app:app /app/_build/prod/rel/stable_crm ./

# Change to app user
USER app

# Set environment
ENV PHX_HOST=0.0.0.0
ENV PORT=4000

# Expose port
EXPOSE 4000

# Run the release
CMD ["bin/stable_crm", "start"]
