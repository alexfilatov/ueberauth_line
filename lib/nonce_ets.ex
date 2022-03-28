defmodule NonceEts do
  @moduledoc """
  ETS implementation for the Nonce
  """

  @behaviour Nonce

  @doc """
  Create new nonce
  """
  @impl true
  def create() do
    nonce = %{
      id: StringGenerator.generate_string(32),
      value: StringGenerator.generate_string(8)
    }

    NonceServer.insert(nonce)

    {:ok, nonce}
  end

  @doc """
  Retrieve nonce if exists
  """
  @impl true
  def get(nonce_id) when is_binary(nonce_id) do
    case NonceServer.get(nonce_id) do
      nonce -> {:ok, nonce}
      _ -> {:error, "nonce with id #{nonce_id} was not found"}
    end
  end

  @doc """
  Dispose existing nonce
  """
  @impl true
  def dispose(%{id: nonce_id}) when is_binary(nonce_id) do
    NonceServer.delete(nonce_id)

    :ok
  end
end
