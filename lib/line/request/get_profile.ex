defmodule Line.Request.GetProfile do
  use TypedStruct

  alias Line.Request.GetProfile
  alias Http.RequestApi

  @behaviour RequestApi

  @endpoint "https://api.line.me/v2/profile"

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%GetProfile{} = request) do
    %{
      method: :get,
      endpoint: @endpoint,
      headers: Mappable.to_map(request, keys: :strings)
    }
  end
end
