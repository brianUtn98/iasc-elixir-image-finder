defmodule ImageLineFetcherSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end

  def start_child(link, target_directory) do
    spec = {ImageLineFetcher, { link, target_directory } }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
