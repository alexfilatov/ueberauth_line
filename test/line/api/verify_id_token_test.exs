defmodule Line.Api.VerifyIdTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Mock
  import Line.ApiTestHelper, only: [response: 3, response: 2]

  alias Line.Api, as: LineApi
  alias Http.Client
  alias Line.Request.{VerifyIdToken}
  alias Line.Response.{Error, OpenId}

  describe "given Line Api verify_id_token" do
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
          endpoint: "https://api.line.me/oauth2/v2.1/verify",
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
          body: %{
            "id_token" => "1234567890",
            "client_id" => "qwqwe",
            "nonce" => "zaq123456",
            "user_id" => "qweqwe"
          }
        }) do
      response(
        200,
        %{
          "iss" => "https://access.line.me",
          "sub" => "U1234567890abcdef1234567890abcdef",
          "aud" => "1234567890",
          "exp" => 1_504_169_092,
          "iat" => 1_504_263_657,
          "amr" => ["pwd"],
          "email" => "taro.line@example.com",
          "picture" => "https://sample_line.me/aBcdefg123456",
          "name" => "Taro Line",
          "nonce" => "0987654asdf"
        }
      )
    end

    def client_request(%{
          method: :post,
          endpoint: "https://api.line.me/oauth2/v2.1/verify",
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
          body: %{
            "id_token" => "1234567890",
            "client_id" => "qwqwe"
          }
        }) do
      response(
        200,
        %{
          "iss" => "https://access.line.me",
          "sub" => "U1234567890abcdef1234567890abcdef",
          "aud" => "1234567890",
          "exp" => 1_504_169_092,
          "iat" => 1_504_263_657,
          "amr" => ["pwd"]
        }
      )
    end

    def client_request(%{
          method: :post,
          endpoint: "https://api.line.me/oauth2/v2.1/verify",
          headers: _,
          body: _
        }) do
      response(
        400,
        %{
          "error" => "invalid_request",
          "error_description" => "Invalid IdToken"
        }
      )
    end

    test "it returns OpenId verification" do
      request = %VerifyIdToken{
        id_token: "1234567890",
        client_id: "qwqwe",
        nonce: "zaq123456",
        user_id: "qweqwe"
      }

      assert %OpenId{
               iss: "https://access.line.me",
               sub: "U1234567890abcdef1234567890abcdef",
               aud: "1234567890",
               exp: 1_504_169_092,
               iat: 1_504_263_657,
               nonce: "0987654asdf",
               amr: ["pwd"],
               name: "Taro Line",
               picture: "https://sample_line.me/aBcdefg123456",
               email: "taro.line@example.com"
             } = LineApi.verify_id_token(request)
    end

    test "it returns OpenId verification without optional fields" do
      request = %VerifyIdToken{
        id_token: "1234567890",
        client_id: "qwqwe"
      }

      assert %OpenId{
               iss: "https://access.line.me",
               sub: "U1234567890abcdef1234567890abcdef",
               aud: "1234567890",
               exp: 1_504_169_092,
               iat: 1_504_263_657,
               amr: ["pwd"]
             } = LineApi.verify_id_token(request)
    end

    test "it returns error with invalid credentials" do
      request = %VerifyIdToken{
        id_token: "invalid",
        client_id: "qwqwe",
        nonce: "zaq123456",
        user_id: "qweqwe"
      }

      assert %Error{} = LineApi.verify_id_token(request)
    end
  end
end
