defmodule Ueberauth.Strategy.Line do
  @moduledoc """
  Line Strategy for Überauth.
  """
  use Ueberauth.Strategy, default_scope: "",
                          profile_fields: "",
                          uid_field: :userId,
                          allowed_request_params: [
                            :auth_type,
                          ]


  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Line authentication.
  """
  def handle_request!(conn) do
    allowed_params = conn
     |> option(:allowed_request_params)
     |> Enum.map(&to_string/1)

    authorize_url = conn.params
      |> Enum.filter(fn {k,_v} -> Enum.member?(allowed_params, k) end)
      |> Enum.map(fn {k,v} -> {String.to_existing_atom(k), v} end)
      |> Keyword.put(:redirect_uri, callback_url(conn))
      |> Keyword.put(:state, "test_state")
      |> Ueberauth.Strategy.Line.OAuth.authorize_url!

    redirect!(conn, authorize_url)
  end

  @doc """
  Handles the callback from Line.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code, "state" => state}} = conn) do
    opts = [redirect_uri: callback_url(conn)]

    case Ueberauth.Strategy.Line.OAuth.get_token!([code: code], opts) do
        %OAuth2.AccessToken{access_token: nil, other_params: other_params} ->
          err = other_params["error"]
          desc = other_params["error_description"]
          set_errors!(conn, [error(err, desc)])
        client ->
          fetch_user(conn, client)
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
      email: user["mid"] ,
      first_name: user["displayName"],
      image: fetch_image(user["pictureUrl"]),
      name: user["displayName"],
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
    default = Dict.get(default_options, key)

    conn
    |> options
    |> Dict.get(key, default)
  end
  defp option(nil, conn, key), do: option(conn, key)
  defp option(value, _conn, _key), do: value
end
