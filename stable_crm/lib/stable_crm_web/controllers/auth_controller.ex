defmodule StableCrmWeb.AuthController do
  use StableCrmWeb, :controller

  alias StableCrm.Accounts
  alias StableCrm.VkIdAuth

  @doc """
  Инициирует процесс авторизации через VK ID.
  Генерирует PKCE параметры и создает URL для авторизации.
  """
  def login(conn, _params) do
    pkce_params = VkIdAuth.generate_pkce_params()
    authorize_url = VkIdAuth.build_authorize_url(pkce_params)

    # Сохраняем PKCE параметры в сессии для последующего использования
    conn
    |> put_session(:pkce_params, pkce_params)
    |> redirect(external: authorize_url)
  end

  @doc """
  Обрабатывает callback от VK ID после успешной авторизации.
  """
  def callback(conn, %{"code" => code, "state" => state, "device_id" => device_id}) do
    # Проверяем state для безопасности
    pkce_params = get_session(conn, :pkce_params)

    if pkce_params && pkce_params.state == state do
      case handle_vk_callback(code, pkce_params.code_verifier, device_id) do
        {:ok, user} ->
          conn
          |> put_session(:user_id, user.id)
          |> delete_session(:pkce_params)
          |> put_flash(:info, "Успешная авторизация!")
          |> redirect(to: ~p"/crm")

        {:error, reason} ->
          conn
          |> delete_session(:pkce_params)
          |> put_flash(:error, "Ошибка авторизации: #{format_error(reason)}")
          |> redirect(to: ~p"/")
      end
    else
      conn
      |> delete_session(:pkce_params)
      |> put_flash(:error, "Неверный state параметр")
      |> redirect(to: ~p"/")
    end
  end

  def callback(conn, %{"error" => error, "error_description" => description}) do
    conn
    |> delete_session(:pkce_params)
    |> put_flash(:error, "Ошибка авторизации: #{error} - #{description}")
    |> redirect(to: ~p"/")
  end

  def callback(conn, _params) do
    conn
    |> delete_session(:pkce_params)
    |> put_flash(:error, "Неверные параметры авторизации")
    |> redirect(to: ~p"/")
  end

  @doc """
  Выход пользователя из системы.
  """
  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Вы успешно вышли из системы")
    |> redirect(to: ~p"/")
  end

  # Private functions

  defp handle_vk_callback(code, code_verifier, device_id) do
    with {:ok, tokens} <- VkIdAuth.exchange_code_for_tokens(code, code_verifier, device_id),
         {:ok, user_info} <- VkIdAuth.get_user_info(tokens.access_token),
         {:ok, user} <- find_or_create_user(user_info, tokens) do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp find_or_create_user(user_info, tokens) do
    case Accounts.get_user_by_vk_id(user_info.vk_user_id) do
      nil ->
        # Создаем нового пользователя
        user_attrs = %{
          email: user_info.email || "vk_#{user_info.vk_user_id}@vk.com",
          name: "#{user_info.first_name} #{user_info.last_name}",
          role: "guest"
        }

        with {:ok, user} <- Accounts.create_user(user_attrs),
             {:ok, _vk_auth} <- Accounts.upsert_vkontakte_auth(user, %{
               vk_user_id: user_info.vk_user_id,
               access_token: tokens.access_token,
               refresh_token: tokens.refresh_token,
               expires_at: tokens.expires_at
             }) do
          {:ok, user}
        end

      user ->
        # Обновляем существующего пользователя
        with {:ok, _vk_auth} <- Accounts.upsert_vkontakte_auth(user, %{
               vk_user_id: user_info.vk_user_id,
               access_token: tokens.access_token,
               refresh_token: tokens.refresh_token,
               expires_at: tokens.expires_at
             }) do
          {:ok, user}
        end
    end
  end

  defp format_error({:vk_id_error, error, description}), do: "#{error}: #{description}"
  defp format_error({:vk_api_error, error}), do: "VK API ошибка: #{inspect(error)}"
  defp format_error({:http_error, status, body}), do: "HTTP ошибка #{status}: #{body}"
  defp format_error({:parse_error, reason}), do: "Ошибка парсинга: #{inspect(reason)}"
  defp format_error({:request_error, reason}), do: "Ошибка запроса: #{inspect(reason)}"
  defp format_error(reason), do: inspect(reason)
end
