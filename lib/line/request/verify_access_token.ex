defmodule Line.Request.VerifyAccessToken do
  use TypedStruct

  alias Http.RequestApi
  alias Line.Request.VerifyAccessToken

  @behaviour RequestApi

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  @spec serialize(t) :: map
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%VerifyAccessToken{} = request) do
    request
    |> Mappable.to_map(keys: :strings)
  end
end
