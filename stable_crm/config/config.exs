# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

import Config

# General application configuration
# See https://hexdocs.pm/elixir/Application.html for more information on OTP Applications
config :stable_crm,
  ecto_repos: [StableCrm.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :stable_crm, StableCrmWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: StableCrmWeb.ErrorHTML, json: StableCrmWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: StableCrm.PubSub,
  live_view: [signing_salt: "Fs7p5hOQ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :stable_crm, StableCrm.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  stable_crm: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  stable_crm: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# VK ID Configuration
config :stable_crm,
  vk_id_client_id: System.get_env("VK_ID_CLIENT_ID") || "your_vk_id_client_id",
  vk_id_client_secret: System.get_env("VK_ID_CLIENT_SECRET") || "your_vk_id_client_secret",
  vk_id_redirect_uri: System.get_env("VK_ID_REDIRECT_URI") || "http://localhost:4000/auth/callback"
