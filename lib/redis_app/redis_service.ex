defmodule RedisApp.RedisService do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    config = Application.get_env(:redis_app, :redis, [])
    {:ok, conn} = Redix.start_link(
      host: Keyword.get(config, :host, "localhost"),
      port: Keyword.get(config, :port, 6379)
    )
    {:ok, conn}
  end

  def get_all_keys do
    GenServer.call(__MODULE__, :get_all_keys)
  end

  def get_value(key) do
    GenServer.call(__MODULE__, {:get_value, key})
  end

  def set_value(key, value) do
    GenServer.call(__MODULE__, {:set_value, key, value})
  end

  def delete_key(key) do
    GenServer.call(__MODULE__, {:delete_key, key})
  end

  def handle_call(:get_all_keys, _from, conn) do
    {:ok, keys} = Redix.command(conn, ["KEYS", "*"])
    {:reply, keys, conn}
  end

  def handle_call({:get_value, key}, _from, conn) do
    {:ok, value} = Redix.command(conn, ["GET", key])
    {:reply, value, conn}
  end

  def handle_call({:set_value, key, value}, _from, conn) do
    {:ok, _} = Redix.command(conn, ["SET", key, value])
    {:reply, :ok, conn}
  end

  def handle_call({:delete_key, key}, _from, conn) do
    {:ok, _} = Redix.command(conn, ["DEL", key])
    {:reply, :ok, conn}
  end
end
