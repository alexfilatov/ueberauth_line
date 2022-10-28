defmodule LineLogin.Client do
  @moduledoc """
  Client for log in flow using Line API.
  """

  use LmHttp.Client, adapter: LineLogin.ClientAdapter
end
