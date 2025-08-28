defmodule StableCrm.VkIdAuth do
  @moduledoc """
  Модуль для работы с VK ID API.
  Реализует OAuth 2.0 flow с PKCE для авторизации через VK ID.
  """

  require Logger

  @vk_id_authorize_url "https://id.vk.com/authorize"
  @vk_id_token_url "https://id.vk.com/oauth2/access_token"
  @vk_id_user_info_url "https://api.vk.com/method/users.get"

  @doc """
  Генерирует параметры PKCE для безопасной авторизации.
  """
  def generate_pkce_params do
    code_verifier = generate_code_verifier()
    code_challenge = generate_code_challenge(code_verifier)

    %{
      code_verifier: code_verifier,
      code_challenge: code_challenge,
      code_challenge_method: "S256",
      state: generate_state()
    }
  end

  @doc """
  Создает URL для авторизации через VK ID.
  """
  def build_authorize_url(params) do
    client_id = get_client_id()
    redirect_uri = get_redirect_uri()

    query_params = %{
      response_type: "code",
      client_id: client_id,
      redirect_uri: redirect_uri,
      code_challenge: params.code_challenge,
      code_challenge_method: params.code_challenge_method,
      state: params.state,
      scope: "vkid.personal_info"
    }

    build_url(@vk_id_authorize_url, query_params)
  end

  @doc """
  Обменивает код авторизации на токены доступа.
  """
  def exchange_code_for_tokens(code, code_verifier, device_id) do
    client_id = get_client_id()
    client_secret = get_client_secret()
    redirect_uri = get_redirect_uri()

    body = %{
      grant_type: "authorization_code",
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code,
      code_verifier: code_verifier,
      device_id: device_id
    }

    case HTTPoison.post(@vk_id_token_url, {:form, body}, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"access_token" => access_token, "refresh_token" => refresh_token, "expires_in" => expires_in}} ->
            expires_at = DateTime.utc_now() |> DateTime.add(expires_in, :second)

            {:ok, %{
              access_token: access_token,
              refresh_token: refresh_token,
              expires_at: expires_at
            }}

          {:ok, %{"error" => error, "error_description" => description}} ->
            Logger.error("VK ID token exchange error: #{error} - #{description}")
            {:error, {:vk_id_error, error, description}}

          {:error, reason} ->
            Logger.error("Failed to parse VK ID response: #{inspect(reason)}")
            {:error, {:parse_error, reason}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("VK ID token exchange failed with status #{status_code}: #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, reason} ->
        Logger.error("VK ID token exchange request failed: #{inspect(reason)}")
        {:error, {:request_error, reason}}
    end
  end

  @doc """
  Получает информацию о пользователе VK.
  """
  def get_user_info(access_token) do
    query_params = %{
      access_token: access_token,
      fields: "id,first_name,last_name,email",
      v: "5.131"
    }

    url = build_url(@vk_id_user_info_url, query_params)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"response" => [user_info | _]}} ->
            {:ok, %{
              vk_user_id: user_info["id"],
              first_name: user_info["first_name"],
              last_name: user_info["last_name"],
              email: user_info["email"]
            }}

          {:ok, %{"error" => error}} ->
            Logger.error("VK API error: #{inspect(error)}")
            {:error, {:vk_api_error, error}}

          {:error, reason} ->
            Logger.error("Failed to parse VK API response: #{inspect(reason)}")
            {:error, {:parse_error, reason}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("VK API request failed with status #{status_code}: #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, reason} ->
        Logger.error("VK API request failed: #{inspect(reason)}")
        {:error, {:request_error, reason}}
    end
  end

  @doc """
  Обновляет токен доступа используя refresh token.
  """
  def refresh_access_token(refresh_token) do
    client_id = get_client_id()
    client_secret = get_client_secret()

    body = %{
      grant_type: "refresh_token",
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: refresh_token
    }

    case HTTPoison.post(@vk_id_token_url, {:form, body}, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"access_token" => access_token, "refresh_token" => new_refresh_token, "expires_in" => expires_in}} ->
            expires_at = DateTime.utc_now() |> DateTime.add(expires_in, :second)

            {:ok, %{
              access_token: access_token,
              refresh_token: new_refresh_token,
              expires_at: expires_at
            }}

          {:ok, %{"error" => error, "error_description" => description}} ->
            Logger.error("VK ID token refresh error: #{error} - #{description}")
            {:error, {:vk_id_error, error, description}}

          {:error, reason} ->
            Logger.error("Failed to parse VK ID refresh response: #{inspect(reason)}")
            {:error, {:parse_error, reason}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("VK ID token refresh failed with status #{status_code}: #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, reason} ->
        Logger.error("VK ID token refresh request failed: #{inspect(reason)}")
        {:error, {:request_error, reason}}
    end
  end

  # Private functions

  defp generate_code_verifier do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, 43)
  end

  defp generate_code_challenge(code_verifier) do
    :crypto.hash(:sha256, code_verifier)
    |> Base.url_encode64(padding: false)
  end

  defp generate_state do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end

  defp build_url(base_url, params) do
    query_string = URI.encode_query(params)
    "#{base_url}?#{query_string}"
  end

  defp get_client_id do
    Application.get_env(:stable_crm, :vk_id_client_id) ||
      System.get_env("VK_ID_CLIENT_ID") ||
      raise "VK ID Client ID not configured"
  end

  defp get_client_secret do
    Application.get_env(:stable_crm, :vk_id_client_secret) ||
      System.get_env("VK_ID_CLIENT_SECRET") ||
      raise "VK ID Client Secret not configured"
  end

  defp get_redirect_uri do
    Application.get_env(:stable_crm, :vk_id_redirect_uri) ||
      System.get_env("VK_ID_REDIRECT_URI") ||
      raise "VK ID Redirect URI not configured"
  end
end
