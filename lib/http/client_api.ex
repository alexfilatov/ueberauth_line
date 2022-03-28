defmodule Http.ClientApi do
  @type t :: module

  @type body :: map()
  @type headers :: tuple()
  @type url :: String.t()

  @type response :: map()

  @doc """
  HTTP GET request.
  """
  @callback get(headers, url) :: {:ok, response} | {:error, String.t()}

  @doc """
  HTTP POST request
  """
  @callback post(body, headers, url) :: {:ok, response} | {:error, String.t()}
end
