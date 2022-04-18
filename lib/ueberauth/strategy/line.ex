defmodule Ueberauth.Strategy.Line do
  @moduledoc """
  Line Login v2.1 Strategy for Überauth.
  """
  use Ueberauth.Strategy,
    default_scope: "",
    profile_fields: "",
    uid_field: :userId,
    allowed_request_params: [
      :auth_type
    ]

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias LineLogin.Api, as: LineApi
  alias LineLogin.Response.{OpenId}
  alias LineLogin.Request.VerifyIdToken

  @doc """
  Handles initial request for Line authentication.
  """
  def handle_request!(conn) do
    allowed_params = get_allowed_params(conn)
    {conn, state} = generate_state(conn)

    authorize_url =
      conn.params
      |> filter_allowed_params(allowed_params)
      |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
      |> Keyword.put(:redirect_uri, callback_url(conn))
      |> Keyword.put(:state, state)
      |> put_scope(conn)
      |> Ueberauth.Strategy.LineLogin.OAuth.authorize_url!()

    redirect!(conn, authorize_url)
  end

  defp get_scope(conn) do
    conn
    |> option(:default_scope)
  end

  defp put_scope(params, conn) do
    scope = get_scope(conn)

    Keyword.put(params, :scope, scope)
  end

  defp get_allowed_params(conn) do
    conn
    |> option(:allowed_request_params)
    |> Enum.map(&to_string/1)
  end

  defp filter_allowed_params(params, allowed_params) do
    params
    |> Enum.filter(fn {k, _v} -> Enum.member?(allowed_params, k) end)
  end

  defp verify_response_state(%Plug.Conn{params: %{"state" => state}} = conn)
       when is_binary(state),
       do: get_session(conn, :line_state) === state

  defp verify_response_state(_), do: false

  defp handle_access_token(
         %Plug.Conn{
           params: %{
             "code" => code
           }
         } = conn
       ) do
    opts = [redirect_uri: callback_url(conn)]

    get_token_result = Ueberauth.Strategy.LineLogin.OAuth.get_token!([code: code], opts)

    case get_token_result do
      %OAuth2.AccessToken{access_token: nil, other_params: other_params} ->
        err = other_params["error"]
        desc = other_params["error_description"]
        set_errors!(conn, [error(err, desc)])

      client ->
        verify_id_token(conn, client)
        |> fetch_user_1(conn, client)

        #        TODO: here handle error and use set_errors!(conn...)
    end
  end

  @doc """
  Handles the callback from LineLogin.
  """
  def handle_callback!(
        %Plug.Conn{
          params: %{
            "code" => code
          }
        } = conn
      ) do
    #    TODO: verify code
    case verify_response_state(conn) do
      true -> aa(conn)
      _ -> set_errors!(conn, [error("invalid_state", "Invalid response state")])
    end
  end

  defp aa(conn) do
    conn
    |> handle_access_token()
  end

  #  TODO: check for existence of the optional fields like picture and email
  defp fetch_user_1({:ok, %OpenId{name: name, email: email, picture: picture}}, conn, client) do
    conn = put_private(conn, :line_token, client.token)

    user = %{
      name: name,
      email: email,
      picture: picture
    }

    put_private(conn, :line_user, user)
  end

  defp fetch_user_1({:error, body}, conn, _) do
    set_errors!(conn, [error("invalid_response", body)])
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_session(:line_state, nil)
    |> put_session(:line_nonce, nil)
    |> put_private(:line_user, nil)
    |> put_private(:line_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.line_user[uid_field]
  end

  @doc """
  Includes the credentials from the line response.
  """
  def credentials(conn) do
    token = conn.private.line_token

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: [],
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the
  `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.line_user

    %Info{
      email: user.email,
      first_name: user.name,
      image: user.picture,
      name: user.name
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from
  the line callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.line_token,
        user: conn.private.line_user
      }
    }
  end

  defp verify_id_token(conn, client) do
    %{client_id: client_id, id_token: id_token} = client
    {conn, nonce} = generate_nonce(conn)

    response =
      %VerifyIdToken{
        id_token: id_token,
        client_id: client_id,
        nonce: nonce
        #    user_id: user_id
      }
      |> LineApi.verify_id_token()

    case response do
      #      TODO: verify nonce
      {:ok, %OpenId{nonce: nonce}} = result -> result
      {:error, %{status: status, body: body}} -> {:error, body}
    end
  end

  defp option(conn, key) do
    default =
      default_options()
      |> Keyword.get(key)

    conn
    |> options
    |> Keyword.get(key, default)
  end

  defp generate_state(conn) do
    state = StringGenerator.generate_string(10)

    {put_session(conn, :line_state, state), state}
  end

  defp generate_nonce(conn) do
    nonce = StringGenerator.generate_string(8)
    {put_session(conn, :line_nonce, nonce), nonce}
  end
end
