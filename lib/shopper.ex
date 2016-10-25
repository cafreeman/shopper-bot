defmodule Shopper do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    slack_token = Application.get_env(:shopper, :slack_token)

    children = [
      worker(Shopper.Store, [Shopper.ShoppingList.new]),
      worker(Shopper.Slack, [slack_token])
    ]

    opts = [strategy: :one_for_one, name: Shopper.Supervisor]
    {:ok, _pid} = Supervisor.start_link(children, opts)
  end
end
