defmodule Namy.Logger do
  require Logger

  def log(message) do
    Logger.debug(prompt() <> message)
  end

  def prompt do
    "#{inspect(__MODULE__)} with pid #{inspect(self())} -> "
  end
end
