defmodule KV.Registry do
  use GenServer
  # TODO: Client API
  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # GenServer Callbacks
  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names_list) do
    {:reply, Map.fetch(names_list, name), names_list}
  end

  @impl true
  def handle_cast({:create, name}, names_list) do
    if Map.has_key?(names_list, name) do
      {:noreply, names_list}
    else
      {:ok, new_bucket} = KV.Bucket.start_link()
      {:noreply, Map.put(names_list, name, new_bucket)}
    end
  end
end
