defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link(juice: 1)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "init with a value", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, :juice) == 1
  end

  test "print the agent state", %{bucket: bucket} do
    KV.Bucket.put(bucket, :carrot, 2)
    assert KV.Bucket.print(bucket) == %{juice: 1, carrot: 2}
  end
end
