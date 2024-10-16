defmodule KV.Registry do
  use GenServer

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
  def lookup_bucket(server, name) do
    GenServer.call(server, {:lookup_name, name})
  end

  def lookup_monitor(server, name) do
    GenServer.call(server, {:lookup_ref, name})
  end

  def print_state(server) do
    GenServer.call(server, :print_state)
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
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup_name, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:lookup_ref, name}, _from, state) do
    {_, refs} = state
    {:reply, Map.fetch(refs, name), state}
  end

  @impl true
  def handle_call(:print_state, _from, state) do
    IO.inspect(state)
    {:reply, :ok, state}
  end

  @impl true
  # Attach monitor on bucket creation
  def handle_cast({:create, name}, {names_list, refs_list}) do
    if Map.has_key?(names_list, name) do
      {:noreply, {names_list, refs_list}}
    else
      {:ok, bucket} = KV.Bucket.start_link()
      ref = Process.monitor(bucket)
      refs_list = Map.put(refs_list, ref, name)
      names_list = Map.put(names_list, name, bucket)
      {:noreply, {names_list, refs_list}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # using pop so we it returns the poped name, so we can use name to delte it from names
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end
