defmodule Shopper.Slack do
  @moduledoc """
  The module for connecting to and interacting with the Slack API. This module is responsible for
  getting/setting data in the DETS store, as well as passing incoming messages to the parser and
  dispatching to the correct behavior (add, clear, info) accordingly.
  """
  use Slack
  alias Shopper.ShoppingList

  @commands_map %{
    "info" => "Display the current contents of the shopping list",
    "add <item1, item2, ...>" => "Take a comma-seaprated list of items and save them to the shopping list",
    "clear" => "Clear out the old shopping list and start a new one"
  }

  def handle_connect(slack) do
    IO.puts "Connected as #{slack.me.name}"
  end

  def handle_message(_message = %{type: "message", subtype: _}, _slack), do: :ok

  # Ignore reply-to messages
  def handle_message(message = %{type: "message", reply_to: _}, _slack), do: :ok

  def handle_message(message = %{type: "message", channel: channel}, slack) do
    case Shopper.Parser.parse(message.text, slack.me.id) do
      :hello -> say_hello(message, slack)
      :info -> show_list_info(message, slack)
      {:add, items_list} -> add_items(items_list, message, slack)
      :clear -> clear_list(message, slack)
      _ -> :ok
    end
  end

  def handle_message(_message, _slack), do: :ok

  defp say_hello(%{channel: channel}, slack) do
    greeting = ~s"Hello there! I'm your friendly shopping bot! Here's what I can help you with:\n"
    commands_message = @commands_map
    |> Enum.map_join("", fn({key, value}) -> "- #{key}: #{value}\n" end)
    # |> Enum.map_join(Enum.map_join("\n", fn({key, value}) -> "- " <> key <> ": " <> value end))

    send_message(greeting <> commands_message, channel, slack)
    :ok
  end

  defp show_list_info(%{channel: channel}, slack) do
    Shopper.Store.get
    |> ShoppingList.info
    |> send_message(channel, slack)
    :ok
  end

  defp add_items(items_list, %{channel: channel}, slack) do
    current_list = Shopper.Store.get

    current_list
    |> ShoppingList.add(items_list)
    |> Shopper.Store.set

    items_list
    |> Enum.join(" ")
    |> (fn(list) -> "The following items have successfully been added to the list:\n" <> list end).()
    |> send_message(channel, slack)

    :ok
  end

  defp clear_list(%{channel: channel}, slack) do
    ShoppingList.new() |> Shopper.Store.set
    send_message("I've created a brand new list for you!", channel, slack)
    :ok
  end

  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key?(slack.ims, channel)
end
