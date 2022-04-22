defmodule LineLogin.Api.VerifyAccessTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias LineLogin.Api, as: LineApi
  alias LineLogin.Request.{VerifyAccessToken}
  alias LineLogin.Response.{Error, VerifiedAccessToken}

  describe "given Line Api verify_access_token" do
    test "it returns VerifiedAccessToken verification" do
      request = %VerifyAccessToken{
        access_token: "access_token_valid"
      }

      assert {:ok,
              %VerifiedAccessToken{
                scope: "profile",
                client_id: "client_id_valid",
                expires_in: 2_591_659
              }} = LineApi.verify_access_token(request)
    end

    test "it returns error for invalid access_token" do
      request = %VerifyAccessToken{
        access_token: "invalid"
      }

      assert {:error, %Error{}} = LineApi.verify_access_token(request)
    end
  end
end
