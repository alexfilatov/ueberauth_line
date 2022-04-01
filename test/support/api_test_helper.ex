defmodule Line.ApiTestHelper do
  def response(status, body, headers \\ %{}), do: %{status: status, body: body, headers: headers}
end
