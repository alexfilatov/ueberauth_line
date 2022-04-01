defmodule Http.ClientApi do
  @type t :: module

  @type body :: map()
  @type query_params :: map()
  @type headers :: tuple()
  @type url :: String.t()

  @type response :: %{status: integer(), body: map(), headers: map()}
  @type result :: {:ok, response} | {:error, String.t()}

  @doc """
  HTTP GET request.
  """
  @callback get(query_params, headers, url) :: result

  @doc """
  HTTP POST request
  """
  @callback post(body, headers, url) :: result
end
