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
      {Config, [:passthrough],
       [
         get_client!: &config_get_client!/0
       ]}
    ]) do
      Code.require_file("test/http/client_mock.exs")

      :ok
    end

    test "it executes GET request" do
      query_params = %{param: :foobar}
      headers = %{foo: :bar}
      url = "some/url"

      assert %{
               mocked: {
                 ^query_params,
                 ^headers,
                 ^url
               }
             } = Client.get(query_params, headers, url)
    end

    test "it executes POST request" do
      body = %{param: 42}
      headers = %{foo: :bar}
      url = "some/url"

      assert %{
               mocked: {
                 ^body,
                 ^headers,
                 ^url
               }
             } = Client.post(body, headers, url)
    end
  end
end
