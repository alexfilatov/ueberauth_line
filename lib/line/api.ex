defmodule Line.Api do
  @moduledoc """
  This module provides an interface to interact with Line Login API v2.1

  TODO:
  - refresh access token
  - revoke access token
  - profile
  - friendship status
  """

  alias Http.Client
  alias Http.RequestApi
  alias Line.Request.{VerifyIdToken, Token, VerifyAccessToken, GetProfile}
  alias Line.Response.{Error, AccessToken, OpenId, VerifiedAccessToken, Profile}

  @header_content_type %{"Content-Type" => "application/x-www-form-urlencoded"}
  @api_issue_access_token "https://api.line.me/oauth2/v2.1/token"
  @api_verify_token "https://api.line.me/oauth2/v2.1/verify"
  @api_profile "https://api.line.me/v2/profile"

  @spec issue_access_token(Token.t()) :: {:ok, AccessToken.t()} | {:error, Error.t()}
  def issue_access_token(%Token{} = request) do
    request
    |> Token.serialize()
    |> Client.post(@header_content_type, @api_issue_access_token)
    |> parse_response(AccessToken)
  end

  @spec verify_access_token(VerifyAccessToken.t()) ::
          {:ok, VerifiedAccessToken.t()} | {:error, Error.t()}
  def verify_access_token(%VerifyAccessToken{} = request) do
    request
    |> VerifyAccessToken.serialize()
    |> Client.get(@header_content_type, @api_verify_token)
    |> parse_response(VerifiedAccessToken)
  end

  @spec verify_id_token(VerifyIdToken.t()) :: {:ok, OpenId.t()} | {:error, Error.t()}
  def verify_id_token(%VerifyIdToken{} = request) do
    request
    |> VerifyIdToken.serialize()
    |> Client.post(@header_content_type, @api_verify_token)
    |> parse_response(OpenId)
  end

  @spec get_profile(GetProfile.t()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(%GetProfile{} = request) do
    # TODO: return headers and body from serialize
    # OR just pass whole RequestApi implementation and inside client, decide how to process it
    # RequestApi must return request type, optional headers and optional body and required url path
    # add signer for OauthRequest that will enrich the header with appropriate Authorization
    request
    |> GetProfile.serialize()
    |> Client.get(@header_content_type, @api_profile)
    |> parse_response(OpenId)
  end

  defp parse_response(%{status: status} = response, type) when status in [200] do
    type.deserialize(response)
  end

  defp parse_response(response, type) do
    Error.deserialize(response)
  end
end
