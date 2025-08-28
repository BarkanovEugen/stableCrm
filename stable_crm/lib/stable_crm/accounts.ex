defmodule StableCrm.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias StableCrm.Repo

  alias StableCrm.Accounts.User
  alias StableCrm.VkontakteAuth

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("nonexistent@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a single user by VK ID.

  ## Examples

      iex> get_user_by_vk_id(12345)
      %User{}

      iex> get_user_by_vk_id(99999)
      nil

  """
  def get_user_by_vk_id(vk_user_id) when is_integer(vk_user_id) do
    User
    |> join(:inner, [u], va in VkontakteAuth, on: u.id == va.user_id)
    |> where([u, va], va.vk_user_id == ^vk_user_id)
    |> select([u, va], u)
    |> Repo.one()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # VK ID Auth functions

  @doc """
  Creates or updates VK ID authorization for a user.

  ## Examples

      iex> upsert_vkontakte_auth(user, %{vk_user_id: 12345, access_token: "token"})
      {:ok, %VkontakteAuth{}}

  """
  def upsert_vkontakte_auth(%User{} = user, attrs) do
    case Repo.get_by(VkontakteAuth, user_id: user.id) do
      nil ->
        # Create new VK auth
        %VkontakteAuth{}
        |> VkontakteAuth.changeset(Map.put(attrs, :user_id, user.id))
        |> Repo.insert()

      existing_auth ->
        # Update existing VK auth
        existing_auth
        |> VkontakteAuth.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Gets VK ID authorization for a user.

  ## Examples

      iex> get_vkontakte_auth(user)
      %VkontakteAuth{}

  """
  def get_vkontakte_auth(%User{} = user) do
    Repo.get_by(VkontakteAuth, user_id: user.id)
  end

  @doc """
  Deletes VK ID authorization for a user.

  ## Examples

      iex> delete_vkontakte_auth(user)
      {:ok, %VkontakteAuth{}}

  """
  def delete_vkontakte_auth(%User{} = user) do
    case get_vkontakte_auth(user) do
      nil -> {:error, :not_found}
      auth -> Repo.delete(auth)
    end
  end
end
