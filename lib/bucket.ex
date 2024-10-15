defmodule KV.Bucket do
  use Agent

  @doc """
  Start the agent with initial value if provided
  """
  def start_link(initial_value \\ %{}) do
    # turn keywords_list into map
    init_map = Enum.into(initial_value, %{})
    Agent.start_link(fn -> init_map end)
  end

  @doc """
  Get the value from the agent
  """
  def get(agent, key) do
    Agent.get(agent, fn agent -> Map.get(agent, key) end)
  end

  @doc """
  Put the value in the agent
  """
  def put(agent, key, value) do
    Agent.update(agent, fn agent -> Map.put(agent, key, value) end)
  end

  @doc """
  Print the agent state
  """
  def print(agent) do
    agent_state = Agent.get(agent, fn agent -> agent end)
    IO.puts("Agent state: #{inspect(agent_state)}")
    agent_state
  end
end
