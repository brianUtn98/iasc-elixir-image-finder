defmodule ImageFinder.Worker do
  use GenServer, ImageLineFetcher

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
    ImageLineFetcherSupervisor.start_link(:ok)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:fetch, source_file, target_directory}, state) do
    content = File.read!(source_file)
    regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
    scanResult = Regex.scan(regexp, content)
    links = Enum.map(scanResult, fn [match | _] -> match end)
    Enum.map(links, fn link ->
      dispatch_fetch(link, target_directory)
  end)
    {:noreply, state}
  end

  def fetch_link(link, target_directory) do
    {:ok, response} = Tesla.get(link)
    response.body |> save(target_directory)
  end

  @spec dispatch_fetch(any(), any()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def dispatch_fetch(link, target_directory) do
    ImageLineFetcherSupervisor.start_child(link, target_directory)
  end

  def digest(body) do
    :crypto.hash(:md5, body) |> Base.encode16()
  end

  def save(body, directory) do
    File.write!("#{directory}/#{digest(body)}", body)
  end
end
