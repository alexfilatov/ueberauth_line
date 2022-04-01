defmodule Line.Response.VerifiedAccessToken do
  use TypedStruct

  alias Http.ClientApi
  alias Line.Response.VerifiedAccessToken

  @behaviour Http.ResponseApi

  typedstruct do
    field(:scope, String.t())
    field(:client_id, String.t())
    field(:expires_in, integer())
  end

  @spec deserialize(ClientApi.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(VerifiedAccessToken)
  end
end
