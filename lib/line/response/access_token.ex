defmodule Line.Response.AccessToken do
  use TypedStruct

  alias Http.ClientApi
  alias Line.Response.AccessToken

  @behaviour Http.ResponseApi

  typedstruct do
    field(:access_token, String.t())
    field(:expires_in, integer())
    field(:id_token, String.t())
    field(:refresh_token, String.t())
    field(:scope, String.t())
    field(:token_type, String.t())
  end

  @spec deserialize(ClientApi.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(AccessToken)
  end
end
