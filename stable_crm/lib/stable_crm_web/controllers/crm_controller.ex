defmodule StableCrmWeb.CrmController do
  use StableCrmWeb, :controller

  alias StableCrm.Accounts

  @doc """
  Показывает главную страницу CRM.
  """
  def index(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Accounts.get_user!(user_id)
      render(conn, :index, user: user)
    else
      conn
      |> put_flash(:error, "Необходима авторизация")
      |> redirect(to: ~p"/")
    end
  end

  @doc """
  Показывает профиль пользователя.
  """
  def profile(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Accounts.get_user!(user_id)
      render(conn, :profile, user: user)
    else
      conn
      |> put_flash(:error, "Необходима авторизация")
      |> redirect(to: ~p"/")
    end
  end
end
