defmodule Line.Api.VerifyAccessTokenTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Mock
  import Line.ApiTestHelper, only: [response: 3, response: 2]

  alias Line.Api, as: LineApi
  alias Http.Client
  alias Line.Request.{VerifyAccessToken}
  alias Line.Response.{Error, VerifiedAccessToken}

  describe "given Line Api verify_access_token" do
    setup_with_mocks([
      {
        Client,
        [:passthrough],
        [
          get: &client_get/3
        ]
      }
    ]) do
      :ok
    end

    def client_get(
          %{
            "access_token" => "abcd123123"
          },
          %{"Content-Type" => "application/x-www-form-urlencoded"},
          "https://api.line.me/oauth2/v2.1/verify"
        ) do
      response(
        200,
        %{
          "scope" => "profile",
          "client_id" => "1440057261",
          "expires_in" => 2_591_659
        }
      )
    end

    def client_get(
          query_params,
          _,
          "https://api.line.me/oauth2/v2.1/verify"
        ) do
      response(
        400,
        %{
          "error" => "invalid_request",
          "error_description" => "access token expired"
        }
      )
    end

    test "it returns VerifiedAccessToken verification" do
      request = %VerifyAccessToken{
        access_token: "abcd123123"
      }

      assert %VerifiedAccessToken{
               scope: "profile",
               client_id: "1440057261",
               expires_in: 2_591_659
             } = LineApi.verify_access_token(request)
    end

    test "it returns error for invalid access_token" do
      request = %VerifyAccessToken{
        access_token: "invalid"
      }

      assert %Error{} = LineApi.verify_access_token(request)
    end
  end
end
