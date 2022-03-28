defmodule NonceServer do
  @moduledoc """
  This is a GenServer for Nonce management
  TODO: add info to readme about this GenServer
  """

  use GenServer

  @ets_name :oauth_nonce

  @doc """
  Start our queue and link it.
  This is a helper function
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    :ets.new(@ets_name, [:set, :protected, :named_table])

    {:ok, state}
  end

  @doc """
  GenServer.handle_call/3 callback
  """
  def handle_call(:insert, %{id: id} = nonce) do
    :ets.insert_new(@ets_name, id, nonce)
  end

  def handle_call(:delete, %{id: id} = nonce) do
    :ets.delete(@ets_name, id)
  end

  def handle_call(:get, nonce_id) when is_binary(nonce_id) do
    case :ets.lookup(@ets_name, nonce_id) do
      [result | _] -> result
      _ -> nil
    end
  end

  def insert, do: GenServer.call(__MODULE__, :insert)
  def delete, do: GenServer.call(__MODULE__, :delete)
  def get, do: GenServer.call(__MODULE__, :get)
end
