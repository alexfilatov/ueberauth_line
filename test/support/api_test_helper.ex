defmodule LineLogin.ApiTestHelper do
  # TODO: move to the LmHttp lib
  def response(status, body, headers \\ %{}), do: %{status: status, body: body, headers: headers}
end
