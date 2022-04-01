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
          post: &client_post/3
        ]
      }
    ]) do
      :ok
    end

    def client_post(
          %{
            "id_token" => "1234567890",
            "client_id" => "qwqwe",
            "nonce" => "zaq123456",
            "user_id" => "qweqwe"
          },
          %{"Content-Type" => "application/x-www-form-urlencoded"},
          "https://api.line.me/oauth2/v2.1/verify"
        ) do
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

    def client_post(
          %{
            "id_token" => "1234567890",
            "client_id" => "qwqwe"
          },
          %{"Content-Type" => "application/x-www-form-urlencoded"},
          "https://api.line.me/oauth2/v2.1/verify"
        ) do
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

    def client_post(
          body,
          _,
          "https://api.line.me/oauth2/v2.1/verify"
        ) do
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

    test "it returns error for invalid credentials" do
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
