defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer
 
  test "caches three most recent pledges" do
    PledgeServer.start()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    assert PledgeServer.recent_pledges |> Enum.count == 3

  end
end