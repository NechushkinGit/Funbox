defmodule Funbox.Repositories.Updater do
  use GenServer

  @tick_interval 60_000

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def add(id), do: GenServer.cast(__MODULE__, {:add, id})

  def remove(id), do: GenServer.cast(__MODULE__, {:remove, id})

  def init(_) do
    tick()
    {:ok, MapSet.new()}
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  def handle_info(:tick, _) do
    Funbox.Repositories.update_libs()
    IO.inspect("Libraries updated!")
    tick()

    {:noreply, :ok}
  end

  def handle_info(_, _), do: {:noreply, :ok}
end
