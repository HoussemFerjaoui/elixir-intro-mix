defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  # setup do
  #   {:ok, server} = KV.Registry.start_link([])
  #   %{server: server}
  # end

  setup do
    server = start_supervised!(KV.Registry)
    %{server: server}
  end

  test "returns error for not found bucket lookup", %{server: server} do
    assert KV.Registry.lookup_bucket(server, "404_bucket") == :error
  end

  test "create & look up a bucket", %{server: server} do
    assert :ok = KV.Registry.create(server, "new_bucket")
    assert {:ok, bucket} = KV.Registry.lookup_bucket(server, "new_bucket")

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "when agent is dead, server should remove the agent as well", %{server: server} do
    KV.Registry.create(server, "my_bucket")
    {:ok, bucket} = KV.Registry.lookup_bucket(server, "my_bucket")
    assert :ok = Agent.stop(bucket)
    assert KV.Registry.lookup_bucket(server, "my_bucket") == :error
  end

  test "print the server state", %{server: server} do
    assert :ok = KV.Registry.print_state(server)
  end
end
