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
    Agent.get(agent, fn agent_state -> Map.get(agent_state, key) end)
  end

  @doc """
  Put the value in the agent
  """
  def put(agent, key, value) do
    Agent.update(agent, fn agent_state -> Map.put(agent_state, key, value) end)
  end

  @doc """
  Print the agent state
  """
  def print(agent) do
    # & can replace agent_state, creation anonymous function on the fly
    # same as Agent.get(agent, fn agent_state -> agent_state end)
    agent_state = Agent.get(agent, & &1)
    IO.puts("Agent state: #{inspect(agent_state)}")
    agent_state
  end
end
