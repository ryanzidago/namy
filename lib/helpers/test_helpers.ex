defmodule Namy.TestHelpers do
  def received do
    receive do
      message -> message
    after
      500 -> nil
    end
  end

  def received(expected) do
    receive do
      message when message == expected -> message
      message -> message
    after
      500 -> nil
    end
  end
end
