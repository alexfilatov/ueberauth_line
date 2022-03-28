defmodule Line.Api do
  @moduledoc """
  TODO: this is a wrapper on the line actions like verify token, authorize requests etc
  keeping all methods in the Line module reduces readability

  to get profile, an openid permission is required

  TODO: maybe separate library as LineApi?
  - is there any behaviour for the Client modules, like PHP's PSR ClientInterface?
  """

  alias Http.Client

  @spec issue_access_token :: {:ok, AccessToken.t()} | {:error, Error.t()}
  def issue_access_token() do
    Client.get()
  end

  def verify_access_token do
  end

  def verify_id_token do
  end

  def get_profile do
  end
end
