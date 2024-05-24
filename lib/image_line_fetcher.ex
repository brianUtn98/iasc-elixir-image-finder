defmodule ImageLineFetcher do
  use GenServer, Tesla
  def start_link(link, target_directory) do
    GenServer.start_link(__MODULE__, {link, target_directory})
  end

  def init(init_state) do
    Process.send_after(self(), :start_fetch, 1000)
    {:ok, init_state}
  end

  def handle_info(:start_fetch, state) do
    GenServer.cast(self(), :fetch)
    {:noreply, state}
  end

  def child_spec({link, target_directory,restart_type}) do
    %{id: random_name(), start: {__MODULE__, :start_link, [link, target_directory]}, type: :worker, restart: restart_type}
  end

  def handle_cast(:fetch, {link, target_directory}) do
    { :ok, response } = Tesla.get(link)
    # TODO: Use response to save the image into a file
    {:noreply, {link, target_directory}}
  end

  def random_name() do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end
end
