defmodule Shopper.Slack do
  @moduledoc """
  The module for connecting to and interacting with the Slack API. This module is responsible for
  getting/setting data in the DETS store, as well as passing incoming messages to the parser and
  dispatching to the correct behavior (add, clear, info) accordingly.
  """
  use Slack
  alias Shopper.ShoppingList

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
