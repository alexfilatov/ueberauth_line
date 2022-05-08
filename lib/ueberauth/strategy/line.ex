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
  alias LineLogin.Crypto.StringGenerator
  alias LineLogin.Crypto.CodeChallenge
  alias LineLogin.Api, as: LineApi
  alias LineLogin.Response.{AccessToken, OpenId, Error}
  alias LineLogin.Request.{Authorize, Token, VerifyIdToken}
  alias LineLogin.OAuth

  @line_authorize_host "https://access.line.me"
  @code_verifier_cookie "ueberauth.line_code_verifier"

  @doc """
  Handles initial request for Line authentication.
  """
  def handle_request!(conn) do
    nonce = StringGenerator.generate_string(8)

    #    TODO: keep nonce in the ets or mnesia because it can't be passed in the cookies. This wouldn't prevent repeated attacks
    # encrypt the nonce with aproppriate sha256
    # set nonce time validity to few minutes (perhaps mnesia can do that)

    code_verifier = CodeChallenge.generate_code_verifier()

    authorize_request =
      [
        response_type: "code"
      ]
      |> put_client_id()
      |> put_redirect_uri(conn)
      |> put_scope(conn)
      |> put_code_challenge(code_verifier)
      |> with_state_param(conn)
      #      |> with_nonce_param(conn)
      |> Authorize.new()

    authorize_url = OAuth.get_authorize_url(@line_authorize_host, authorize_request)

    conn
    |> put_resp_cookie(@code_verifier_cookie, code_verifier, same_site: "Lax")
    |> redirect!(authorize_url)
  end

  defp put_code_challenge(params, code_verifier) do
    %{
      code_challenge: code_challenge,
      code_challenge_method: code_challenge_method
    } = CodeChallenge.get_code_challenge(code_verifier)

    params
    |> Keyword.put(:code_challenge, code_challenge)
    |> Keyword.put(:code_challenge_method, code_challenge_method)
  end

  defp put_redirect_uri(params, conn), do: Keyword.put(params, :redirect_uri, callback_url(conn))

  defp get_scope(conn), do: option(conn, :default_scope)

  defp put_scope(params, conn) do
    scope = get_scope(conn)

    Keyword.put(params, :scope, scope)
  end

  defp put_client_id(params) do
    %{client_id: client_id} = get_credentials()

    Keyword.put(params, :client_id, client_id)
  end

  defp get_config, do: Application.get_env(:ueberauth, Ueberauth.Strategy.Line.OAuth)

  # TODO: check field exists
  defp get_credentials() do
    config = get_config()

    %{
      client_id: config[:client_id],
      client_secret: config[:client_secret]
    }
  end

  #  TODO: extract to separate module to ease validation
  # also build connection should be extracted

  @doc """
  Handles the callback from Line.
  """
  def handle_callback!(
        %Plug.Conn{
          params: %{
            "code" => code,
            "state" => state
          },
          req_cookies: %{
            "ueberauth.state_param" => state
          }
        } = conn
      )
      when is_binary(code) and is_binary(state) do
    %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: callback_url(conn),
      code_verifier: fetch_code_verifier!(conn)
    }
    |> Map.merge(get_credentials())
    |> Token.new()
    |> LineApi.issue_access_token()
    |> verify_id_token(conn)
  end

  def handle_callback!(
        %Plug.Conn{
          params: %{
            "code" => code
          }
        } = conn
      )
      when not is_binary(code) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("csrf_failed", "Invalid response state")])
  end

  defp fetch_code_verifier!(conn) do
    case get_code_verifier_cookie(conn) do
      nil -> raise "could not fetch the code verifier"
      code_verifier -> code_verifier
    end
  end

  defp get_code_verifier_cookie(conn) do
    conn
    |> fetch_session()
    |> Map.get(:cookies)
    |> Map.get(@code_verifier_cookie)
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

  @doc """
  Add nonce parameter to the `%Plug.Conn{}`.
  """
  @spec add_nonce_param(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  def add_nonce_param(conn, value) do
    put_private(conn, :ueberauth_nonce_param, value)
  end

  @spec with_nonce_param(
          keyword(),
          Plug.Conn.t()
        ) :: keyword()
  def with_nonce_param(opts, conn) do
    nonce = conn.private[:ueberauth_nonce_param]

    if is_nil(nonce) do
      opts
    else
      Keyword.put(opts, :nonce, nonce)
    end
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:line_state, nil)
    |> put_private(:line_nonce, nil)
    |> put_private(:line_user, nil)
    |> put_private(:line_token, nil)
    |> delete_resp_cookie(@code_verifier_cookie)
  end

  defp get_fake_sso_email(user_id) do
    "#{user_id}@sso.line.me"
  end

  #  TODO: check nonce in OpenId whether matches nonce stored in mnesia/ets
  defp fetch_user({:ok, %OpenId{sub: sub, name: name, email: email, picture: picture}}, conn)
       when is_nil(email) do
    user = %{
      name: name,
      email: get_fake_sso_email(sub),
      picture: picture
    }

    conn
    |> put_private(:line_user, user)
  end

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
end
