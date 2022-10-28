defmodule LineLogin.Api.IssueAccessTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias LineLogin.Api, as: LineApi
  alias LineLogin.Request.{Token}
  alias LineLogin.Response.{Error, AccessToken}

  describe "given Line Api issue_access_token" do
    test "it returns access token" do
      request = %Token{
        grant_type: "authorization_code",
        code: "valid_code",
        redirect_uri: "https://example.com/auth?key=value",
        client_id: "client_id_valid",
        client_secret: "client_secret_valid",
        code_verifier: "wJKN8qz5t8SSI9lMFhBB6qwNkQBkuPZoCxzRhwLRUo1"
      }

      assert {:ok,
              %AccessToken{
                access_token: "access_token_valid",
                expires_in: 2_592_000,
                id_token: "id_token_valid",
                refresh_token: "Aa1FdeggRhTnPNNpxr8p",
                scope: "profile",
                token_type: "Bearer"
              }} = LineApi.issue_access_token(request)
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

      assert {:error, %Error{}} = LineApi.issue_access_token(request)
    end
  end
end
