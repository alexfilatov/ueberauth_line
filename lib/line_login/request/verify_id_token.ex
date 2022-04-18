defmodule LineLogin.Request.VerifyIdToken do
  use TypedStruct

  alias LineLogin.Request.VerifyIdToken
  alias LmHttp.RequestApi
  alias LmHttp.Payload

  @behaviour RequestApi

  @endpoint "https://api.line.me/oauth2/v2.1/verify"

  typedstruct enforce: true do
    field(:id_token, String.t())
    field(:client_id, String.t())
    field(:user_id, String.t(), enforce: false)
    field(:nonce, String.t(), enforce: false)
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%VerifyIdToken{} = request) do
    %{
      method: :post,
      endpoint: @endpoint,
      headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
      body: prepare_body(request)
    }
  end

  defp prepare_body(request) do
    request
    |> Mappable.to_map(keys: :strings)
    |> Payload.remove_nils()
  end
end
