defmodule Line.Request.GetProfile do
  use TypedStruct

  alias Line.Request.GetProfile

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  @spec serialize(t) :: map
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%GetProfile{} = request) do
    request
    |> Mappable.to_map(keys: :strings)
  end
end
