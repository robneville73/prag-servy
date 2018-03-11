defmodule Servy.SensorServer do

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.seconds(1200)
  end

  @name :sensor_server

  use GenServer

  alias Servy.VideoCam

  # Client interface
  def start_link(interval) do
    IO.puts "Starting the sensor server with interval #{interval} sec refresh..."
    GenServer.start_link(__MODULE__, %State{refresh_interval: :timer.seconds(interval)}, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(new_timeout) do
    GenServer.cast @name, {:set_refresh_interval, new_timeout}
  end

  # Server callbacks
  def init(state) do
    state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    schedule_refresh(state.refresh_interval)
    {:ok, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache..."
    new_sensor_data = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:noreply, %{state | sensor_data: new_sensor_data}}
  end

  def handle_cast({:set_refresh_interval, new_timeout}, state) do
    new_state = %{state | refresh_interval: :timer.seconds(new_timeout)}
    schedule_refresh(new_state.refresh_interval)
    {:noreply, new_state}
  end

  defp schedule_refresh(timeout) do
    Process.send_after(self(), :refresh, timeout)
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(Servy.Tracker, :get_location, ["bigfoot"])

    snapshots = 
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end

end