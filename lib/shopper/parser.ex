defmodule Shopper.Parser do
  @moduledoc """
  The parser for incoming slack messages.

  Current parses out the following commands:
  - info
  - add
  - clear

  An empty message (.e.g "@shopper") will also trigger the "info" match
  """
  @items_regex ~r/\s*(\w+)\s*/

  def parse(message, my_id) do
    cond do
      message =~ make_command_regex(my_id, "(?:info)?") -> :info
      message =~ make_command_regex(my_id, "clear") -> :clear

      message =~ make_command_regex(my_id, "add", ".*") ->
        items_list = message
        |> strip_add
        |> extract_items

        case items_list do
          [] -> :add
          _ -> {:add, items_list}
        end

      true -> nil
    end
  end

  def extract_items(message) do
    @items_regex
    |> Regex.scan(message)
    |> Enum.flat_map(fn(pair) -> tl(pair) end)
  end

  defp strip_add(message) do
    case Regex.split(~r/(?<=add)(\s+)/, message) do
      [_, items] -> items
      [_] -> ""
    end
  end

  defp make_command_regex(my_id, command, suffix \\ "") when is_binary(command) do
    case Regex.compile(~s"^\s*<@#{my_id}>:?\s*#{command}\s*#{suffix}$") do
      {:ok, compiled} -> compiled
      {:error, _} -> raise("Invalid regex!")
    end
  end
end
