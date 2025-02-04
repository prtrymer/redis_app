defmodule RedisApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: RedisApp.PubSub},
      RedisAppWeb.Endpoint,
      RedisApp.RedisService
    ]

    opts = [strategy: :one_for_one, name: RedisApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RedisAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
