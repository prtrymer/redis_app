defmodule RedisApp.RedisServiceTest do
  use ExUnit.Case

  setup do
    {:ok, conn} = Redix.start_link()
    Redix.command(conn, ["FLUSHALL"])
    on_exit(fn ->
      if Process.alive?(conn) do
        Redix.command(conn, ["FLUSHALL"])
        Redix.stop(conn)
      end
    end)
    :ok
  end

  test "set and get value" do
    :ok = RedisApp.RedisService.set_value("test_key", "test_value")
    assert RedisApp.RedisService.get_value("test_key") == "test_value"
  end

  test "delete key" do
    :ok = RedisApp.RedisService.set_value("delete_key", "some_value")
    :ok = RedisApp.RedisService.delete_key("delete_key")
    assert RedisApp.RedisService.get_value("delete_key") == nil
  end

  test "get all keys" do
    :ok = RedisApp.RedisService.set_value("key1", "value1")
    :ok = RedisApp.RedisService.set_value("key2", "value2")
    keys = RedisApp.RedisService.get_all_keys()
    assert "key1" in keys
    assert "key2" in keys
  end
end
