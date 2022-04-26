defmodule Ueberauth.Strategy.LineTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Plug.Conn
  import Ueberauth.Strategy.Helpers

  @url_auth "/auth/line"
  @url_callback "/auth/line/callback"

  setup do
    # Create a connection with Ueberauth's CSRF cookies so they can be recycled during tests
    routes = Ueberauth.init([])

    csrf_conn =
      conn(:get, @url_auth, %{})
      |> Plug.Test.init_test_session(%{line_state: "TEST-state"})
      |> Ueberauth.call(routes)

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

  defp set_csrf_cookies(conn, csrf_conn) do
    conn
    |> init_test_session(%{})
    |> recycle_cookies(csrf_conn)
    |> fetch_cookies()
  end

  test "handle_request! redirects to appropriate auth uri" do
    conn =
      conn(:get, @url_auth, %{})
      |> init_test_session(%{})

    routes =
      Ueberauth.init()
      |> set_options(conn, hd: "example.com", default_scope: "profile openid email")

    resp = Ueberauth.call(conn, routes)

    assert resp.status == 302
    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)
    assert redirect_uri.host == "access.line.me"
    assert redirect_uri.path == "/oauth2/v2.1/authorize"

    assert %{
             "client_id" => "client_id_valid",
             "redirect_uri" => "http://www.example.com/auth/line/callback",
             "response_type" => "code",
             "scope" => "profile openid email",
             "code_challenge" => _,
             "code_challenge_method" => "S256"
           } = Plug.Conn.Query.decode(redirect_uri.query)
  end

  test "handle_callback! assigns required fields on successful auth", %{
    csrf_state: csrf_state,
    csrf_conn: csrf_conn
  } do
    conn =
      conn(:get, @url_callback, %{code: "success_code", state: csrf_state})
      |> put_private(:line_state, csrf_state)
      |> set_csrf_cookies(csrf_conn)

    routes = Ueberauth.init([])
    assert %Plug.Conn{assigns: %{ueberauth_auth: auth}} = Ueberauth.call(conn, routes)

    assert auth.credentials.token == "access_token_valid"
    assert auth.info.name == "Taro Line"
    assert auth.info.email == "taro.line@example.com"
  end

  test "state param is present in the redirect uri" do
    conn =
      conn(:get, @url_auth, %{})
      |> Plug.Test.init_test_session(%{line_state: "TEST-state"})

    routes = Ueberauth.init()
    resp = Ueberauth.call(conn, routes)

    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)

    assert redirect_uri.query =~ "state="
  end
end
