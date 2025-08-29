# Multi-stage build for production
FROM elixir:1.15-alpine as builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm

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
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    libstdc++

# Create app user
RUN adduser -D -s /bin/sh app

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
