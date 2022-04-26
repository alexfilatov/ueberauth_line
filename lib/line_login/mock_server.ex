defmodule LineLogin.MockServer do
  use Plug.Router

  require Logger

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/x-www-form-urlencoded"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  #  TODO: return matching access_tokens etc because they must be used in the integration flow

  @doc """
  Verify ID token. Nonce is optional.
  """
  post "/oauth2/v2.1/verify" do
    case conn.body_params do
      %{
        "id_token" => "id_token_valid",
        "client_id" => "client_id_valid",
        "nonce" => nonce
      } ->
        id_token_success(conn, %{nonce: nonce})

      %{
        "id_token" => "id_token_valid",
        "client_id" => "client_id_valid"
      } ->
        id_token_success(conn, %{})

      _ ->
        id_token_error(conn)
    end
  end

  defp id_token_success_body(%{nonce: nonce}) do
    id_token_success_body(%{})
    |> Map.put("nonce", nonce)
  end

  defp id_token_success_body(_) do
    %{
      "iss" => "https://access.line.me",
      "sub" => "U1234567890abcdef1234567890abcdef",
      "aud" => "1234567890",
      "exp" => 1_504_169_092,
      "iat" => 1_504_263_657,
      "amr" => ["pwd"],
      "email" => "taro.line@example.com",
      "picture" => "https://sample_line.me/aBcdefg123456",
      "name" => "Taro Line"
    }
  end

  defp id_token_success(conn, params) do
    success(conn, id_token_success_body(params))
  end

  defp id_token_error(conn) do
    log_debug(conn.body_params)

    failure(conn, %{
      "error" => "invalid_request",
      "error_description" => "Invalid IdToken"
    })
  end

  get "/oauth2/v2.1/verify" do
    case conn.params do
      %{
        "access_token" => "access_token_valid"
      } ->
        verify_success(conn)

      _ ->
        verify_error(conn)
    end
  end

  defp verify_success(conn) do
    success(conn, %{
      "scope" => "profile",
      "client_id" => "client_id_valid",
      "expires_in" => 2_591_659
    })
  end

  defp verify_error(conn) do
    log_debug(conn.params)

    failure(conn, %{
      "error" => "invalid_request",
      "error_description" => "access token expired"
    })
  end

  post "/oauth2/v2.1/token" do
    case conn.body_params do
      %{
        "grant_type" => "authorization_code",
        "code" => _,
        "redirect_uri" => _,
        "client_id" => "client_id_valid",
        "client_secret" => "client_secret_valid",
        "code_verifier" => _code_verifier
      } ->
        token_success(conn)

      _ ->
        token_error(conn)
    end
  end

  defp token_success(conn) do
    success(conn, %{
      "access_token" => "access_token_valid",
      "expires_in" => 2_592_000,
      "id_token" => "id_token_valid",
      "refresh_token" => "Aa1FdeggRhTnPNNpxr8p",
      "scope" => "profile",
      "token_type" => "Bearer"
    })
  end

  defp token_error(conn) do
    log_debug(conn.body_params)

    failure(conn, %{
      "error" => "invalid_request",
      "error_description" => "invalid clientId"
    })
  end

  defp success(conn, body) do
    conn
    |> Plug.Conn.send_resp(200, Jason.encode!(body))
  end

  defp failure(conn, body) do
    conn
    |> Plug.Conn.send_resp(400, Jason.encode!(body))
  end

  defp log_debug(data) do
    Logger.debug(fn ->
      """
      Received #{__MODULE__}:

      #{inspect(data, pretty: true)}
      """
    end)
  end
end
