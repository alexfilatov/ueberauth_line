defmodule Http.ClientTest do
  use ExUnit.Case, async: true

  import Mock

  alias Http.Client
  alias Http.Config
  alias Http.ClientMock

  defp config_get_client!() do
    ClientMock
  end

  describe "given Config with configured client" do
    setup_with_mocks([
      {
        Config,
        [:passthrough],
        [
          get_client!: &config_get_client!/0
        ]
      }
    ]) do
      Code.require_file("test/http/client_mock.exs")

      :ok
    end

    test "it executes request" do
      serialized = %{
        method: :post,
        endpoint: "https://example.com/url",
        headers: %{
          foo: :bar
        },
        body: %{
          param: :foobar
        }
      }

      assert %{
               mocked: ^serialized
             } = Client.request(serialized)
    end
  end
end
