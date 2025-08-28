defmodule StableCrm.Repo do
  use Ecto.Repo,
    otp_app: :stable_crm,
    adapter: Ecto.Adapters.Postgres
end
