defmodule Servy.FourOhFourCounter do

  @name __MODULE__

  use GenServer

  # client interface
  def start_link(_arg) do
    IO.puts "Starting the 404 Counter server..."
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def bump_count(path) do
    GenServer.call @name, {:bump_count, path}
  end

  def get_count(path) do
    GenServer.call @name, {:get_count, path}
  end

  def get_counts do
    GenServer.call @name, :get_counts
  end

  # server

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_count, path}, _from, state) do
    {:reply, Map.get(state, path, 0), state}
  end

  def handle_call({:bump_count, path}, _from, state) do
    state = Map.update(state, path, 1, fn curr_val -> curr_val + 1 end)
    {:reply, {:ok, state}, state}
  end

end