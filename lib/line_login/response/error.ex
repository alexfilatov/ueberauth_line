defmodule LineLogin.Response.Error do
  @moduledoc """
  Line Login Error response struct and deserializer.
  """

  use TypedStruct

  alias LineLogin.ClientAdapter
  alias LineLogin.Response.Error

  @behaviour LmHttp.ResponseApi

  typedstruct do
    field(:error, String.t())
    field(:error_description, String.t(), default: "")
  end

  @spec deserialize(ClientAdapter.response()) :: t
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
