defmodule Http.RequestApi do
  @type t :: module

  alias Http.RequestApi

  @type serialized_request :: %{headers: map, body: map}

  @doc """
  Serialize the Request into map
  """
  @callback serialize(RequestApi.t()) :: map()
end
