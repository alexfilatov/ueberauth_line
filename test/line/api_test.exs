defmodule Line.ApiTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Mock

  alias Line.Api, as: LineApi
  alias Http.Client
  alias Line.Request.{VerifyIdToken, Token}
  alias Line.Response.{Error, AccessToken, OpenId}

  describe "given Line Api issue_access_token" do
    setup_with_mocks([
      {
        Client,
        [:passthrough],
        [
          get: &client_get/2,
          post: &client_post/3
        ]
      }
    ]) do
      :ok
    end

    def client_get(headers, url) do
      %{}
    end

    def client_post(
          body,
          %{"Content-Type" => "application/x-www-form-urlencoded"},
          "https://api.line.me/oauth2/v2.1/token"
        ) do
      %{
        "access_token" => "bNl4YEFPI/hjFWhTqexp4MuEw5YPs",
        "expires_in" => 2_592_000,
        "id_token" => "eyJhbGciOiJIUzI1NiJ9",
        "refresh_token" => "Aa1FdeggRhTnPNNpxr8p",
        "scope" => "profile",
        "token_type" => "Bearer"
      }
    end

    test "it returns access token" do
      request = %Token{
        grant_type: "authorization_code",
        code: "1234567890abcde",
        redirect_uri: "https://example.com/auth?key=value",
        client_id: "1234567890",
        client_secret: "1234567890abcdefghij1234567890ab",
        code_verifier: "wJKN8qz5t8SSI9lMFhBB6qwNkQBkuPZoCxzRhwLRUo1"
      }

      assert %AccessToken{
               access_token: "bNl4YEFPI/hjFWhTqexp4MuEw5YPs",
               expires_in: 2_592_000,
               id_token: "eyJhbGciOiJIUzI1NiJ9",
               refresh_token: "Aa1FdeggRhTnPNNpxr8p",
               scope: "profile",
               token_type: "Bearer"
             } = LineApi.issue_access_token(request)
    end
  end
end
