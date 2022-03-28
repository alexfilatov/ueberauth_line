defmodule Line.Api do
  @moduledoc """
  TODO: this is a wrapper on the line actions like verify token, authorize requests etc
  keeping all methods in the Line module reduces readability

  to get profile, an openid permission is required
  """

  alias Http.Client
  alias Http.RequestApi
  alias Line.Request.{VerifyIdToken, Token}
  alias Line.Response.{Error, AccessToken, OpenId}

  @header_content_type %{"Content-Type" => "application/x-www-form-urlencoded"}
  @api_issue_access_token "https://api.line.me/oauth2/v2.1/token"

  @spec issue_access_token(Token.t()) :: {:ok, AccessToken.t()} | {:error, Error.t()}
  def issue_access_token(%Token{} = request) do
    request
    |> Token.serialize()
    |> Client.post(@header_content_type, @api_issue_access_token)
    |> parse_response(AccessToken)
  end

  @spec verify_access_token :: {:ok, AccessToken.t()} | {:error, Error.t()}
  def verify_access_token do
  end

  @spec verify_id_token(VerifyIdToken.t()) :: {:ok, OpenId.t()} | {:error, Error.t()}
  def verify_id_token(request) do
  end

  @spec get_profile :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile do
  end

  defp parse_response(%{"error" => error} = response, type) do
    Error.deserialize(response)
  end

  defp parse_response(%{} = response, type) do
    type.deserialize(response)
  end
end
