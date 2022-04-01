defmodule Line.Request.Token do
  use TypedStruct

  alias Http.RequestApi
  alias Line.Request.Token

  @behaviour RequestApi

  typedstruct enforce: true do
    field(:grant_type, String.t())
    field(:code, String.t())
    field(:redirect_uri, String.t())
    field(:client_id, String.t())
    field(:client_secret, String.t())
    field(:code_verifier, String.t(), enforce: false)
  end

  @spec serialize(t) :: map
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%Token{} = request) do
    request
    |> Mappable.to_map(keys: :strings)
  end
end
