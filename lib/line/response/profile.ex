defmodule Line.Response.Profile do
  use TypedStruct

  alias Line.Response.Profile

  typedstruct do
    field(:user_id, String.t())
    field(:display_name, String.t())
    field(:picture_url, String.t())
    field(:status_message, String.t())
  end

  @spec deserialize(ClientApi.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(Profile)
  end
end
