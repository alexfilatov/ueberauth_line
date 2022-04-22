defmodule LineLogin.Client do
  use LmHttp.Client, adapter: LineLogin.ClientAdapter
end
