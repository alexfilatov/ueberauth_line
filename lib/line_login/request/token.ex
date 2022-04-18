defmodule LineLogin.Request.Token do
  use TypedStruct

  alias LmHttp.RequestApi
  alias LineLogin.Request.Token
  alias LmHttp.RequestApi
  alias LmHttp.Payload

  @behaviour RequestApi

  @endpoint "https://api.line.me/oauth2/v2.1/token"

  typedstruct enforce: true do
    field(:grant_type, String.t())
    field(:code, String.t())
    field(:redirect_uri, String.t())
    field(:client_id, String.t())
    field(:client_secret, String.t())
    field(:code_verifier, String.t(), enforce: false)
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%Token{} = request) do
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
