defmodule Servy.FourOhFourCounter do

  @name __MODULE__

  # client interface
  def start do
    pid = spawn(__MODULE__, :loop, [%{}])
    Process.register(pid, @name)
  end

  def bump_count(path) do
    send @name, {self(), :bump_count, path}

    receive do {:ok, _state} -> :ok end
  end

  def get_count(path) do
    send @name, {self(), :get_count, path}

    receive do {:ok, count} -> count end
  end

  def get_counts do
    send @name, {self(), :get_counts}

    receive do {:ok, sum} -> sum end
  end

  # server

  def loop(state) do
    receive do
      {sender, :bump_count, path} ->
        state = Map.update(state, path, 1, fn curr_val -> curr_val + 1 end)
        send sender, {:ok, state}
        loop(state)
      {sender, :get_count, path} ->
        value = Map.get(state, path, 0)
        send sender, {:ok, value}
        loop(state)
      {sender, :get_counts} ->
        send sender, {:ok, state}
        loop(state)
      unknown ->
        IO.puts "Unknown message type of #{inspect unknown}"
        loop(state)
    end
  end
end