defmodule Http.ConfigTest do
  use ExUnit.Case, async: false

  import Mock

  alias Http.Config
  alias Http.ClientMock

  describe "given Application without configured client" do
    test "it raises an exception" do
      assert_raise RuntimeError, "HTTP argument :client for :http_client is not configured", fn ->
        Config.get_client!()
      end
    end
  end

  defp application_get_env(:http_client, Http.Client, _) do
    [
      client: ClientMock
    ]
  end

  describe "given Application with configured client" do
    setup_with_mocks([
      {Application, [:passthrough],
       [
         get_env: &application_get_env/3
       ]}
    ]) do
      :ok
    end

    test "it returns the client" do
      assert ClientMock = Config.get_client!()
    end
  end
end
