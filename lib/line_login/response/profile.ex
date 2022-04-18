defmodule LineLogin.Response.Profile do
  use TypedStruct

  alias LineLogin.Response.Profile

  @behaviour LmHttp.ResponseApi

  typedstruct do
    field(:user_id, String.t())
    field(:display_name, String.t())
    field(:picture_url, String.t())
    field(:status_message, String.t())
  end

  @spec deserialize(ClientAdapter.response()) :: t
  @impl true
  def deserialize(%{body: body}) when is_map(body) do
    body
    |> Mappable.to_struct(Profile)
  end
end
