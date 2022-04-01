defmodule Line.Response.OpenId do
  use TypedStruct

  alias Line.Response.OpenId

  @behaviour Http.ResponseApi

  typedstruct do
    field(:iss, String.t())
    field(:sub, String.t())
    field(:aud, String.t())
    field(:exp, integer())
    field(:iat, integer())
    field(:amr, [String.t()])
    field(:email, String.t())
    field(:picture, String.t())
    field(:name, String.t())
    field(:nonce, String.t())
  end

  @spec deserialize(ClientApi.response()) :: t
  @impl true
  def deserialize(%{body: body}) do
    body
    |> Mappable.to_struct(OpenId)
  end
end
