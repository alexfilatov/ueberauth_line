defmodule Ueberauth.Strategy.LineTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import Plug.Conn
  import Ueberauth.Strategy.Helpers

  #  https://developers.line.biz/en/reference/line-login/#issue-token-http-request
  # POST
  @api_issue_token "https://api.line.me/oauth2/v2.1/token"
  #  Verify uses GET to verify access token and POST to verify ID token
  @api_verify_token "https://api.line.me/oauth2/v2.1/verify"
  # POST
  @api_revoke_token "https://api.line.me/oauth2/v2.1/revoke"
  #  GET
  @api_profile "https://api.line.me/v2/profile"

  #  Collect sample responses for each endpoint

  @url_auth "/auth/line"
  @url_callback "/auth/line/callback"

  setup_with_mocks([
    {OAuth2.Client, [:passthrough],
     [
       get_token!: &oauth2_get_token!/2,
       get: &oauth2_get/2,
       post: &oauth2_post/3
     ]}
  ]) do
    # Create a connection with Ueberauth's CSRF cookies so they can be recycled during tests
    routes = Ueberauth.init([])
    csrf_conn = conn(:get, @url_auth, %{}) |> Ueberauth.call(routes)
    csrf_state = with_state_param([], csrf_conn) |> Keyword.get(:state)

    {:ok, csrf_conn: csrf_conn, csrf_state: csrf_state}
  end

  def set_options(routes, conn, opt) do
    case Enum.find_index(routes, &(elem(&1, 0) == {conn.request_path, conn.method})) do
      nil ->
        routes

      idx ->
        update_in(routes, [Access.at(idx), Access.elem(1), Access.elem(2)], &%{&1 | options: opt})
    end
  end

  defp token(client, opts), do: %{client | token: OAuth2.AccessToken.new(opts)}
  defp response(body, code \\ 200), do: {:ok, %OAuth2.Response{status_code: code, body: body}}

  def oauth2_get_token!(client, code: "success_code") do
    token(client, "success_token")
    |> Map.put(:id_token, "success_id_token")
  end

  def oauth2_get(%{token: %{access_token: "expired_token"}}, @api_verify_token),
    do:
      response(%{
        scope: "profile",
        client_id: "randomClientId1234",
        expires_in: 0
      })

  def oauth2_get(%{token: %{access_token: "success_token"}}, @api_verify_token),
    do:
      response(%{
        scope: "profile",
        client_id: "randomClientId1234",
        expires_in: 2_591_659
      })

  def oauth2_get(%{token: %{access_token: "success_token"}}, @api_profile),
    do:
      response(%{
        userId: "U4af4980629",
        displayName: "John Wick",
        pictureUrl: "https://profile.line-scdn.net/abcdefghijklmn",
        statusMessage: "Hello, LINE!"
      })

  def oauth2_post(_, @api_verify_token, %{client_id: _, id_token: "success_id_token"}),
    do:
      response(%{
        iss: "https://access.line.me",
        sub: "U1234567890abcdef1234567890abcdef",
        aud: "1234567890",
        exp: 1_504_169_092,
        iat: 1_504_263_657,
        nonce: "0987654asdf",
        amr: ["pwd"],
        name: "John Wick",
        picture: "https://sample_line.me/aBcdefg123456",
        email: "john.wick@example.com"
      })

  defp set_csrf_cookies(conn, csrf_conn) do
    conn
    |> init_test_session(%{})
    |> recycle_cookies(csrf_conn)
    |> fetch_cookies()
  end

  test "handle_request! redirects to appropriate auth uri" do
    conn = conn(:get, @url_auth, %{})

    routes =
      Ueberauth.init()
      |> set_options(conn, hd: "example.com", default_scope: "profile%20openid%20email")

    resp = Ueberauth.call(conn, routes)

    assert resp.status == 302
    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)
    assert redirect_uri.host == "access.line.me"
    assert redirect_uri.path == "/oauth2/v2.1/authorize"

    assert %{
             "client_id" => "randomClientId1234",
             "redirect_uri" => "http://www.example.com/auth/line/callback",
             "response_type" => "code",
             "scope" => "profile%20openid%20email"
           } = Plug.Conn.Query.decode(redirect_uri.query)
  end

  test "handle_callback! assigns required fields on successful auth", %{
    csrf_state: csrf_state,
    csrf_conn: csrf_conn
  } do
    conn =
      conn(:get, @url_callback, %{code: "success_code", state: csrf_state})
      |> set_csrf_cookies(csrf_conn)

    #      TODO: get idToken and use it to retrieve user details
    #      TODO: add token verify request, because then response will match expected pattern
    routes = Ueberauth.init([])
    assert %Plug.Conn{assigns: %{ueberauth_auth: auth}} = Ueberauth.call(conn, routes)
    assert auth.credentials.token == "success_token"
    assert auth.info.name == "John Wick"
    assert auth.info.email == "john.wick@example.com"
  end

  test "state param is present in the redirect uri" do
    conn = conn(:get, @url_auth, %{})

    routes = Ueberauth.init()
    resp = Ueberauth.call(conn, routes)

    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)

    assert redirect_uri.query =~ "state="
  end
end
