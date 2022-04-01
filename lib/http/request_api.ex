defmodule Http.RequestApi do
  @type t :: module

  alias Http.ClientApi
  alias Http.RequestApi

  @doc """
  Serialize the Request into map
  """
  @callback serialize(RequestApi.t()) :: ClientApi.serialized_request()
end
