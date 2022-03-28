defmodule Http.ResponseApi do
  @type t :: module

  alias Http.ResponseApi

  @doc """
  Deserialize raw response into response structure
  """
  @callback deserialize(%{}) :: ResponseApi
end
