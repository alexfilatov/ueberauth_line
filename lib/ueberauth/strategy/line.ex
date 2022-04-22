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
  alias LineLogin.Response.{AccessToken, OpenId, Error}
  alias LineLogin.Request.{Token, VerifyIdToken}

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
      |> with_state_param(conn)
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

  defp get_config do
    Application.get_env(:ueberauth, Ueberauth.Strategy.Line.OAuth)
  end

  # TODO: check field exists
  defp get_credentials() do
    config = get_config()

    %{
      client_id: config[:client_id],
      client_secret: config[:client_secret]
    }
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

  @doc """
  Handles the callback from Line.
  """
  def handle_callback!(
        %Plug.Conn{
          params: %{
            "code" => code,
            "state" => state
          }
        } = conn
      )
      when is_binary(code) and is_binary(state) do
    #    TODO: verify code and state
    #    handle_access_token(conn)
    %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: callback_url(conn),
      #    TODO: generate code and store in cookie
      code_verifier: "wJKN8qz5t8SSI9lMFhBB6qwNkQBkuPZoCxzRhwLRUo1"
    }
    |> Map.merge(get_credentials())
    |> Token.new()
    |> LineApi.issue_access_token()
    |> verify_id_token(conn)
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  defp verify_id_token({:ok, %AccessToken{id_token: id_token} = token}, conn)
       when is_binary(id_token) do
    %{client_id: client_id} = get_credentials()

    conn = put_private(conn, :line_token, token)

    %VerifyIdToken{
      id_token: id_token,
      client_id: client_id
      #    TODO: dynamic nonce
      #      nonce: "zaq123456"
    }
    |> LineApi.verify_id_token()
    |> fetch_user(conn)
  end

  defp verify_id_token({:error, %Error{error: error, error_description: error_desc}}, conn) do
    set_errors!(conn, [error(error, error_desc)])
  end

  defp verify_id_token(response, conn) do
    set_errors!(conn, [
      error("missing_id_token", "No Id Token received. Response: " <> inspect(response))
    ])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:line_state, nil)
    |> put_private(:line_nonce, nil)
    |> put_private(:line_user, nil)
    |> put_private(:line_token, nil)
  end

  #  TODO: check for existence of the optional fields like picture and email
  defp fetch_user({:ok, %OpenId{name: name, email: email, picture: picture}}, conn) do
    user = %{
      name: name,
      email: email,
      picture: picture
    }

    conn
    |> put_private(:line_user, user)
  end

  defp fetch_user(response, conn) do
    set_errors!(conn, [error("invalid_response", inspect(response))])
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(%{private: %{line_user: user}} = conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    user[uid_field]
  end

  def uid(conn) do
    set_errors!(conn, [error("invalid_struct", "Cannot fetch uid")])
  end

  @doc """
  Includes the credentials from the line response.
  """
  def credentials(%{private: %{line_token: token}}) do
    %Credentials{
      expires: !!token.expires_in,
      expires_at: token.expires_in,
      scopes: [],
      token: token.access_token
    }
  end

  def credentials(conn) do
    set_errors!(conn, [error("invalid_struct", "Cannot fetch credentials")])
  end

  @doc """
  Fetches the fields to populate the info section of the
  `Ueberauth.Auth` struct.
  """
  def info(%{private: %{line_user: user}}) do
    %Info{
      email: user.email,
      first_name: user.name,
      image: user.picture,
      name: user.name
    }
  end

  def info(conn) do
    set_errors!(conn, [error("invalid_struct", "Cannot fetch info")])
  end

  @doc """
  Stores the raw information (including the token) obtained from
  the line callback.
  """
  def extra(%{private: %{line_token: token, line_user: user}}) do
    %Extra{
      raw_info: %{
        token: token,
        user: user
      }
    }
  end

  def extra(conn) do
    set_errors!(conn, [error("invalid_struct", "Cannot fetch extra")])
  end

  defp option(conn, key) do
    default =
      default_options()
      |> Keyword.get(key)

    conn
    |> options
    |> Keyword.get(key, default)
  end

  defp generate_nonce(conn) do
    nonce = StringGenerator.generate_string(8)

    {put_private(conn, :line_nonce, nonce), nonce}
  end
end
