defmodule Http.ClientApi do
  alias Http.RequestApi

  @type t :: module

  @type body :: map()
  @type query_params :: map()
  @type headers :: tuple()
  @type url :: String.t()

  @type endpoint :: String.t()
  @type http_method :: atom()

  @type serialized_request :: %{method: http_method, endpoint: endpoint, headers: map, body: map}
  @type response :: %{status: integer(), body: map(), headers: map()}
  @type result :: {:ok, response} | {:error, String.t()}

  @doc """
  Generic request.
  """
  @callback request(serialized_request) :: result
end
