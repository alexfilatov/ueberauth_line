defmodule Line.Response.Error do
  use TypedStruct

  alias Http.ClientApi
  alias Line.Response.Error

  @behaviour Http.ResponseApi

  typedstruct do
    field(:error, String.t())
    field(:error_description, String.t(), default: "")
  end

  @spec deserialize(ClientApi.response()) :: t
  @impl true
  def deserialize(%{
        status: status,
        body: body
      })
      when status >= 400 and is_map(body) do
    body
    |> Mappable.to_struct(Error)
  end
end
