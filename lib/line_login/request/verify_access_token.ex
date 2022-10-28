defmodule LineLogin.Request.VerifyAccessToken do
  @moduledoc """
  Line Login 2.1 Verify Access Token serializer and request struct.
  """

  use TypedStruct

  alias LineLogin.Request.VerifyAccessToken
  alias LmHttp.RequestApi

  @behaviour RequestApi

  @endpoint "/oauth2/v2.1/verify"

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  def new(data) when is_map(data) do
    struct!(VerifyAccessToken, data)
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%VerifyAccessToken{} = request) do
    %{
      method: :get,
      endpoint: @endpoint <> "?access_token=#{request.access_token}",
      headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
    }
  end
end
