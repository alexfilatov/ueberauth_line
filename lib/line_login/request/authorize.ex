defmodule LineLogin.Request.Authorize do
  use TypedStruct

  alias LmHttp.RequestApi
  alias LineLogin.Request.Authorize
  alias LmHttp.RequestApi
  alias LmHttp.Payload

  @behaviour RequestApi

  @endpoint "/oauth2/v2.1/authorize"

  typedstruct enforce: true do
    field(:response_type, String.t())
    field(:client_id, String.t())
    field(:redirect_uri, String.t())
    field(:state, String.t())
    field(:scope, String.t())
    field(:nonce, String.t(), enforce: false)
    field(:code_challenge, String.t(), enforce: false)
    field(:code_challenge_method, String.t(), enforce: false)
  end

  def new(data) do
    struct!(Authorize, data)
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%Authorize{} = request) do
    %{
      method: :get,
      endpoint: @endpoint,
      headers: [{"Content-Type", "application/x-www-form-urlencoded"}],
      body: prepare_body(request)
    }
  end

  defp prepare_body(request) do
    request
    |> Mappable.to_map(keys: :strings)
    |> Payload.remove_nils()
    |> maybe_format_scope
    |> Payload.to_keyword()
  end

  defp maybe_format_scope(%{"scope" => scope} = params) when is_binary(scope) do
    formatted_scope = String.replace(scope, " ", "%20")

    Map.put(params, "scope", formatted_scope)
  end

  defp maybe_format_scope(params), do: params
end
