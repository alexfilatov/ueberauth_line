defmodule LineLogin.Response.VerifiedAccessToken do
  use TypedStruct

  alias LmHttp.ClientAdapter
  alias LineLogin.Response.VerifiedAccessToken

  @behaviour LmHttp.ResponseApi

  typedstruct do
    field(:scope, String.t())
    field(:client_id, String.t())
    field(:expires_in, integer())
  end

  @spec deserialize(ClientAdapter.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(VerifiedAccessToken)
  end
end
