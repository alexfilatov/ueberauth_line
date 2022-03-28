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

  @doc """
  Handles initial request for Line authentication.
  """
  def handle_request!(conn) do
    allowed_params = get_allowed_params(conn)

    authorize_url =
      conn.params
      |> filter_allowed_params(allowed_params)
      |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
      |> Keyword.put(:redirect_uri, callback_url(conn))
      |> put_scope(conn)
      |> generate_and_put_state()
      |> Ueberauth.Strategy.Line.OAuth.authorize_url!()

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

  defp generate_and_put_state(params) do
    state = generate_state()

    Keyword.put(params, :state, state)
  end

  @doc """
  Handles the callback from Line.
  """
  def handle_callback!(
        %Plug.Conn{
          params: %{
            "code" => code,
            "state" => _
          }
        } = conn
      ) do
    opts = [redirect_uri: callback_url(conn)]

    get_token_result = Ueberauth.Strategy.Line.OAuth.get_token!([code: code], opts)

    case get_token_result do
      %OAuth2.AccessToken{access_token: nil, other_params: other_params} ->
        err = other_params["error"]
        desc = other_params["error_description"]
        set_errors!(conn, [error(err, desc)])

      #      client ->
      #        try_fetch_user(conn, client)
      client ->
        verify_id_token(conn, client)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
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

  # TODO: Implement this
  defp fetch_image(image_url) do
    image_url
  end

  defp is_token_valid?(%{client_id: client_id}, %{client_id: client_id, expires_in: expires_in})
       when expires_in > 0,
       do: true

  defp is_token_valid?(_client, _response), do: false

  defp validate_token_response(conn, client, body) do
    case is_token_valid?(client, body) do
      true ->
        {:ok, client}

      _ ->
        {:error, "invalid token"}
    end
  end

  defp validate_token(conn, %{token: token} = client) do
    url = "https://api.line.me/oauth2/v2.1/verify"

    response = OAuth2.Client.get(client, url)

    case response do
      {:ok, %OAuth2.Response{status_code: 200, body: body}} ->
        validate_token_response(conn, client, body)

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp verify_id_token(conn, client) do
    url = "https://api.line.me/oauth2/v2.1/verify"

    %{client_id: client_id, id_token: id_token} = client

    params = %{
      # nonce: nonce,
      client_id: client_id,
      id_token: id_token
    }

    response = OAuth2.Client.post(client, url, params)

    case response do
      {:ok, %OAuth2.Response{status_code: 200, body: body}} ->
        convert_user(conn, body)
        |> put_private(:line_token, client.token)

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp convert_user(conn, %{email: email, name: name, picture: picture}) do
    #    TODO: test against specified scope:
    #    Not included if the profile scope wasn't specified in the authorization request.
    user = %{
      email: email,
      name: name,
      picture: picture
    }

    put_private(conn, :line_user, user)
  end

  defp try_fetch_user(conn, client) do
    case validate_token(conn, client) do
      {:ok, client} ->
        fetch_user(conn, client)

      {:error, reason} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp fetch_user(conn, client) do
    conn = put_private(conn, :line_token, client.token)
    url = "https://api.line.me/v2/profile"

    response = OAuth2.Client.get(client, url)

    case response do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :line_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
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

  defp generate_state do
    StringGenerator.generate_string(10)
  end

  defp generate_nonce do
    StringGenerator.generate_string(8)
  end
end
