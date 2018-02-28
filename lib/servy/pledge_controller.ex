defmodule Servy.PledgeController do

  import View, only: [render: 3, render: 2]

  def new(conv) do
    render(conv, "new_pledge.eex")
  end

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!" }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = Servy.PledgeServer.recent_pledges()
      |> Enum.map(fn t -> %{name: elem(t,0), amount: elem(t,1)} end)
    
    render(conv, "pledges.eex", pledges: pledges)
  end

end
