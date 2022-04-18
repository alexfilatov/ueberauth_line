defmodule LineLogin.Request.VerifyAccessToken do
  use TypedStruct

  alias LmHttp.RequestApi
  alias LineLogin.Request.VerifyAccessToken
  alias LmHttp.RequestApi

  @behaviour RequestApi

  @endpoint "https://api.line.me/oauth2/v2.1/verify"

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%VerifyAccessToken{} = request) do
    %{
      method: :get,
      endpoint: @endpoint,
      headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
      body: Mappable.to_map(request, keys: :strings)
    }
  end
end
