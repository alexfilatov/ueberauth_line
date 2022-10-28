defmodule LineLogin.ApiTestHelper do
  @moduledoc """
  Mock API request helpers.
  """

  # TODO: move to the LmHttp lib
  def response(status, body, headers \\ %{}), do: %{status: status, body: body, headers: headers}
end
