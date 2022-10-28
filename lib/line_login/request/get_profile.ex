defmodule LineLogin.Request.GetProfile do
  @moduledoc """
  Line Login 2.1 Get Profile serializer and request struct.
  """

  use TypedStruct

  alias LineLogin.Request.GetProfile
  alias LmHttp.RequestApi
  alias LmHttp.Payload

  @behaviour RequestApi

  @endpoint "/v2/profile"

  typedstruct enforce: true do
    field(:access_token, String.t())
  end

  def new(data) when is_map(data) do
    struct!(GetProfile, data)
  end

  @spec serialize(t) :: RequestApi.serialized_request()
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%GetProfile{} = request) do
    %{
      method: :get,
      endpoint: @endpoint,
      headers: prepare_body(request)
    }
  end

  defp prepare_body(request) do
    request
    |> Mappable.to_map(keys: :strings)
    |> Payload.remove_nils()
    |> Payload.to_keyword()
  end
end
