defmodule LineLogin.Response.AccessToken do
  use TypedStruct

  alias LmHttp.ClientAdapter
  alias LineLogin.Response.AccessToken

  @behaviour LmHttp.ResponseApi

  typedstruct do
    field(:access_token, String.t())
    field(:expires_in, integer())
    field(:id_token, String.t())
    field(:refresh_token, String.t())
    field(:scope, String.t())
    field(:token_type, String.t())
  end

  @spec deserialize(ClientAdapter.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(AccessToken)
  end
end
