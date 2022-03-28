defmodule NonceMnesia do
  @moduledoc """
  Mnesia implementation for the Nonce
  """

  @behaviour Nonce

  @doc """
  Create new nonce
  """
  @impl true
  def create() do
    #   {:ok, nonce} | {:error, String.t}
  end

  @doc """
  Retrieve nonce if exists
  """
  @impl true
  def get(nonce_id) when is_binary(nonce_id) do
    #   {:ok, nonce} | {:error, String.t}
  end

  @doc """
  Dispose existing nonce
  """
  @impl true
  def dispose(%{id: nonce_id}) when is_binary(nonce_id) do
    #   :ok | {:error, String.t}
  end
end
