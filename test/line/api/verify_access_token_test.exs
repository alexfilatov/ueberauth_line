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
          request: &client_request/1
        ]
      }
    ]) do
      :ok
    end

    def client_request(%{
          method: :get,
          endpoint: "https://api.line.me/oauth2/v2.1/verify",
          body: %{
            "access_token" => "abcd123123"
          },
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"}
        }) do
      response(
        200,
        %{
          "scope" => "profile",
          "client_id" => "1440057261",
          "expires_in" => 2_591_659
        }
      )
    end

    def client_request(%{
          method: :get,
          endpoint: "https://api.line.me/oauth2/v2.1/verify",
          body: _,
          headers: _
        }) do
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
