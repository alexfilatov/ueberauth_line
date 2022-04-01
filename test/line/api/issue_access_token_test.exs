defmodule Line.Api.IssueAccessTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Mock
  import Line.ApiTestHelper, only: [response: 3, response: 2]

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
          request: &client_request/1
        ]
      }
    ]) do
      :ok
    end

    def client_request(%{
          method: :post,
          endpoint: "https://api.line.me/oauth2/v2.1/token",
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
          body: %{"client_id" => "1234567890"}
        }) do
      response(
        200,
        %{
          "access_token" => "bNl4YEFPI/hjFWhTqexp4MuEw5YPs",
          "expires_in" => 2_592_000,
          "id_token" => "eyJhbGciOiJIUzI1NiJ9",
          "refresh_token" => "Aa1FdeggRhTnPNNpxr8p",
          "scope" => "profile",
          "token_type" => "Bearer"
        }
      )
    end

    def client_request(%{
          method: :post,
          endpoint: "https://api.line.me/oauth2/v2.1/token",
          headers: _,
          body: _
        }) do
      response(
        400,
        %{
          "error" => "invalid_request",
          "error_description" => "invalid clientId"
        }
      )
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

    test "it returns error for invalid credentials" do
      request = %Token{
        grant_type: "authorization_code",
        code: "1234567890abcde",
        redirect_uri: "https://example.com/auth?key=value",
        client_id: "invalid-id",
        client_secret: "1234567890abcdefghij1234567890ab",
        code_verifier: "wJKN8qz5t8SSI9lMFhBB6qwNkQBkuPZoCxzRhwLRUo1"
      }

      assert %Error{} = LineApi.issue_access_token(request)
    end
  end
end
