defmodule Http.ClientMock do
  @moduledoc """
  This is a Client Mock for testing purposes. It returns provided parameters as the test verification.
  """

  alias Http.ClientApi

  @behaviour Http.ClientApi

  @type mocked_response :: %{mocked: {}}

  @spec get(ClientApi.query_params(), ClientApi.headers(), ClientApi.url()) :: mocked_response
  @doc """
  Mocked GET response. Returns provided parameters as test verification
  """
  @impl true
  def get(query_params, headers, url) do
    %{mocked: {query_params, headers, url}}
  end

  @spec post(ClientApi.body(), ClientApi.headers(), ClientApi.url()) :: mocked_response
  @doc """
  Mocked POST response. Returns provided parameters as test verification
  """
  @impl true
  def post(body, headers, url) do
    %{mocked: {body, headers, url}}
  end
end
