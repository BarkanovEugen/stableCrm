defmodule StableCrm.Repo.Migrations.CreateVkontakteAuths do
  use Ecto.Migration

  def change do
    create table(:vkontakte_auths) do
      add :vk_user_id, :integer
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:vkontakte_auths, [:user_id])
    create unique_index(:vkontakte_auths, [:vk_user_id])
  end
end
