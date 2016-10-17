defmodule Shopper.Parser do
  @moduledoc """
  The parser for incoming slack messages.

  Current parses out the following commands:
  - info
  - add
  - clear

  An empty message (.e.g "@shopper") will also trigger the "info" match
  """
  # ~R/<@(\w+)>:?\s*(\w+)/

  def parse(message, my_id) do
    IO.puts(message)
    cond do
      message =~ ~r/^\s*<@#{my_id}>:?\s*(?:info)?\s*$/ -> :info
      message =~ ~r/^\s*<@#{my_id}>:?\s*add\s*$/ -> :add
      message =~ ~r/^\s*<@#{my_id}>:?\s*clear\s*$/ -> :clear
      true -> nil
    end

  end
end
