defmodule Shopper.Slack do
  use Slack

  def handle_connect(slack) do
    IO.puts "Connected as #{slack.me.name}"
  end

  def handle_message(_message = %{type: "message", subtype: _}, _slack), do: :ok

  # Ignore reply-to messages
  def handle_message(message = %{type: "message", reply_to: _}, _slack), do: :ok

  def handle_message(message = %{type: "message", channel: channel}, slack) do
    case Shopper.Parser.parse(message.text, slack.me.id) do
      :info -> show_list_info(message, slack)
      {:add, items_list} -> add_items(items_list, message, slack)
      :clear -> clear_list(message, slack)
      _ -> :ok
    end
  end

  def handle_message(_message, _slack), do: :ok

  defp show_list_info(%{channel: channel}, slack) do
    Shopper.Store.get
    |> Shopper.ShoppingList.info
    |> send_message(channel, slack)
    :ok
  end

  defp add_items(items_list, %{channel: channel}, slack) do
    current_list = Shopper.Store.get

    current_list
    |> Shopper.ShoppingList.add(items_list)
    |> Shopper.Store.set

    items_list
    |> Enum.join(" ")
    |> (fn(list) -> "The following items have successfully been added to the list:\n" <> list end).()
    |> send_message(channel, slack)

    :ok
  end

  defp clear_list(%{channel: channel}, slack) do
    send_message("You requrested clear!", channel, slack)
    :ok
  end

  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key?(slack.ims, channel)
end
