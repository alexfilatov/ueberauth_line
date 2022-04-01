defmodule Line.Api do
  @moduledoc """
  This module provides an interface to interact with Line Login API v2.1

  TODO:
  - refresh access token
  - revoke access token
  - friendship status
  """

  alias Http.Client
  alias Http.RequestApi
  alias Line.Request.{VerifyIdToken, Token, VerifyAccessToken, GetProfile}
  alias Line.Response.{Error, AccessToken, OpenId, VerifiedAccessToken, Profile}

  @spec issue_access_token(Token.t()) :: {:ok, AccessToken.t()} | {:error, Error.t()}
  def issue_access_token(%Token{} = request) do
    request
    |> Token.serialize()
    |> Client.request()
    |> parse_response(AccessToken)
  end

  @spec verify_access_token(VerifyAccessToken.t()) ::
          {:ok, VerifiedAccessToken.t()} | {:error, Error.t()}
  def verify_access_token(%VerifyAccessToken{} = request) do
    request
    |> VerifyAccessToken.serialize()
    |> Client.request()
    |> parse_response(VerifiedAccessToken)
  end

  @spec verify_id_token(VerifyIdToken.t()) :: {:ok, OpenId.t()} | {:error, Error.t()}
  def verify_id_token(%VerifyIdToken{} = request) do
    request
    |> VerifyIdToken.serialize()
    |> Client.request()
    |> parse_response(OpenId)
  end

  @spec get_profile(GetProfile.t()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(%GetProfile{} = request) do
    request
    |> GetProfile.serialize()
    |> Client.request()
    |> parse_response(OpenId)
  end

  defp parse_response(%{status: status} = response, type) when status in [200] do
    type.deserialize(response)
  end

  defp parse_response(response, type) do
    Error.deserialize(response)
  end
end
