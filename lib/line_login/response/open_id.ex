defmodule LineLogin.Response.OpenId do
  use TypedStruct

  alias LineLogin.Response.OpenId

  @behaviour LmHttp.ResponseApi

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

  @spec deserialize(ClientAdapter.response()) :: t
  @impl true
  def deserialize(%{body: body}) do
    body
    |> Mappable.to_struct(OpenId)
  end
end
