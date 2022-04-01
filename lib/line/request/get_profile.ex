defmodule Line.Request.VerifyIdToken do
  use TypedStruct

  alias Line.Request.VerifyIdToken

  typedstruct enforce: true do
    field(:id_token, String.t())
    field(:client_id, String.t())
    field(:user_id, String.t(), enforce: false)
    field(:nonce, String.t(), enforce: false)
  end

  @spec serialize(t) :: map
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%VerifyIdToken{} = request) do
    request
    |> Mappable.to_map(keys: :strings)
  end
end
