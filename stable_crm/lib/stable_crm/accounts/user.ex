defmodule StableCrm.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :role, :string, default: "guest"

    has_one :vkontakte_auth, StableCrm.VkontakteAuth

    timestamps(type: :utc_datetime)
  end

  @roles ["admin", "manager", "client", "guest"]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :role])
    |> validate_required([:email, :name])
    |> validate_email()
    |> validate_role()
    |> unique_constraint(:email)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, min: 3, max: 255)
  end

  defp validate_role(changeset) do
    changeset
    |> validate_inclusion(:role, @roles)
  end

  def admin?(user), do: user.role == "admin"
  def manager?(user), do: user.role == "manager" or user.role == "admin"
  def client?(user), do: user.role == "client" or user.role == "manager" or user.role == "admin"
end
