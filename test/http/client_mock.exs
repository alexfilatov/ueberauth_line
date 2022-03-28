defmodule Http.ClientMock do
  @moduledoc """
  This is a Client Mock for testing purposes.
  """

  @behaviour Http.ClientApi

  @type url :: String.t()
  @type mocked_response :: %{mocked: {}}

  @spec get(map, String.t()) :: mocked_response
  @doc """
  Mocked GET response. Returns provided parameters as test verification
  """
  @impl true
  def get(headers, url) do
    %{mocked: {headers, url}}
  end

  @spec post(map, map, String.t()) :: mocked_response
  @doc """
  Mocked POST response. Returns provided parameters as test verification
  """
  @impl true
  def post(body, headers, url) do
    %{mocked: {body, headers, url}}
  end
end
