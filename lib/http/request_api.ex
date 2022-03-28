defmodule Http.RequestApi do
  @type t :: module

  alias Http.RequestApi

  @doc """
  Serialize the Request into map
  """
  @callback serialize(RequestApi.t()) :: %{}
end
