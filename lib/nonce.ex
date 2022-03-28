defmodule Nonce do
  @type nonce :: %{id: binary(), value: String.t()}

  @doc """
  Create new nonce
  """
  @callback create() :: {:ok, nonce} | {:error, String.t()}

  @doc """
  Retrieve nonce if exists
  """
  @callback get(binary()) :: {:ok, nonce} | {:error, String.t()}

  @doc """
  Dispose existing nonce
  """
  @callback dispose(nonce()) :: :ok | {:error, String.t()}
end
