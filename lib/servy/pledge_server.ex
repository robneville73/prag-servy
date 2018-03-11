
defmodule Servy.PledgeServer do

  @name __MODULE__

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # def child_spec(_arg) do
  #   %{id: Servy.PledgeServer, restart: :temporary, shutdown: 5000,
  #     start: {Servy.PledgeServer, :start_link, [[]]}, type: :worker}
  # end

  # Client interface
  def start_link(_arg) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenServer.call @name, :total_pledged
  end

  def clear do
    GenServer.cast @name, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  # Server Callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{ state | pledges: pledges }
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{ state | pledges: []} }
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{ state | cache_size: size }
    new_state = %{ state | pledges: cached_pledges(new_state)}
    {:noreply, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_cached_pledges = [ {name, amount} | cached_pledges(state) ]
    new_state = %{ state | pledges: new_cached_pledges }
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.puts "Can't touch this #{inspect message}"
    {:noreply, state}
  end

  defp cached_pledges(state) do
    Enum.take(state.pledges, state.cache_size - 1)
  end

  defp send_pledge_to_service(_name, _amount) do
    #code goes here to send to service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE goes here to fetch recent pledges from external service

    # example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start()

# send pid, {:stop, "hammer-time"}
# PledgeServer.set_cache_size(4)
# IO.inspect PledgeServer.create_pledge("larry", 10)
# #PledgeServer.clear()
# # IO.inspect PledgeServer.create_pledge("moe", 20)
# # IO.inspect PledgeServer.create_pledge("curly", 30)
# # IO.inspect PledgeServer.create_pledge("daisy", 40)
# # IO.inspect PledgeServer.create_pledge("grace", 50)

# IO.inspect PledgeServer.recent_pledges

# IO.inspect PledgeServer.total_pledged

# IO.inspect Process.info(pid, :messages)
