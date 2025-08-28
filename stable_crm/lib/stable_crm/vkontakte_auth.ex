defmodule StableCrm.VkontakteAuth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vkontakte_auths" do
    field :vk_user_id, :integer
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    belongs_to :user, StableCrm.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vkontakte_auth, attrs) do
    vkontakte_auth
    |> cast(attrs, [:vk_user_id, :access_token, :refresh_token, :expires_at, :user_id])
    |> validate_required([:vk_user_id, :access_token, :refresh_token, :expires_at, :user_id])
    |> validate_number(:vk_user_id, greater_than: 0)
    |> unique_constraint(:vk_user_id)
    |> unique_constraint(:user_id)
    |> foreign_key_constraint(:user_id)
  end

  def expired?(auth) do
    case auth.expires_at do
      nil -> true
      expires_at -> DateTime.compare(DateTime.utc_now(), expires_at) == :gt
    end
  end

  def needs_refresh?(auth) do
    case auth.expires_at do
      nil -> true
      expires_at ->
        # Обновляем токен за 5 минут до истечения
        refresh_time = DateTime.add(expires_at, -300, :second)
        DateTime.compare(DateTime.utc_now(), refresh_time) == :gt
    end
  end
end
