defmodule LineLogin.Client do
  use LmHttp.Client, adapter: LmHttpHackney.ClientAdapter
end
