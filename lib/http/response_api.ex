defmodule Http.ResponseApi do
  @type t :: module

  alias Http.ResponseApi
  alias Http.ClientApi

  @doc """
  Deserialize raw response into response structure
  """
  @callback deserialize(ClientApi.response()) :: ResponseApi
end
