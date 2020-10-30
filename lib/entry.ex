defmodule Namy.Entry do
  def lookup(requested_name, entries) do
    case Enum.find(entries, fn {name, _pid} = _entry -> name == requested_name end) do
      nil -> :unknown
      result -> result
    end
  end

  def add(name, entry, entries) do
    [{name, entry} | entries]
  end

  def remove(name, entries) do
    Enum.reject(entries, fn {entry_name, _entry} -> entry_name == name end)
  end
end
