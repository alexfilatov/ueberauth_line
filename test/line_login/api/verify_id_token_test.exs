defmodule LineLogin.Api.VerifyIdTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias LineLogin.Api, as: LineApi
  alias LineLogin.Request.{VerifyIdToken}
  alias LineLogin.Response.{Error, OpenId}

  describe "given Line Api verify_id_token" do
    test "it returns OpenId verification" do
      request = %VerifyIdToken{
        id_token: "id_token_valid",
        client_id: "client_id_valid",
        user_id: "qweqwe"
      }

      assert {:ok,
              %OpenId{
                iss: "https://access.line.me",
                sub: "U1234567890abcdef1234567890abcdef",
                aud: "1234567890",
                exp: 1_504_169_092,
                iat: 1_504_263_657,
                amr: ["pwd"],
                name: "Taro Line",
                picture: "https://sample_line.me/aBcdefg123456",
                email: "taro.line@example.com"
              }} = LineApi.verify_id_token(request)
    end

    test "it returns error with invalid credentials" do
      request = %VerifyIdToken{
        id_token: "invalid",
        client_id: "qwqwe",
        user_id: "qweqwe"
      }

      assert {:error, %Error{}} = LineApi.verify_id_token(request)
    end
  end
end
