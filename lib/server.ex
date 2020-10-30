defmodule Namy.Server do
  @moduledoc """
  Servers are responsible for a domain
  and holds a set of registered hosts and sub-domain servers.
  Servers form a tree structure.
  """
  alias Namy.Entry

  def start do
    pid = spawn(__MODULE__, :init, [])
    Process.register(pid, __MODULE__)
  end

  def start(domain, dns) do
    pid = spawn(__MODULE__, :init, [domain, dns])
    Process.register(pid, __MODULE__)
  end

  def stop do
    send(self(), :stop)
    Process.unregister(__MODULE__)
  end

  def init do
    server([], 0)
  end

  def init(domain, parent) do
    send(parent, {:register, domain, {:dns, self()}})
    server([], 0)
  end

  defp server(entries, ttl) do
    receive do
      {:request, from, name} ->
        IO.inspect("Received request #{name}")
        reply = Entry.lookup(name, entries)
        send(from, {reply, ttl})
        IO.inspect("Sent reply: #{reply}")
        server(entries, ttl)

      {:register, name, entry} ->
        updated_entries = Entry.add(name, entry, entries)
        IO.inspect("Updated entries: #{updated_entries}")
        server(updated_entries, ttl)

      {:deregister, name} ->
        updated_entries = Entry.remove(name, entries)
        IO.inspect("Updated entries: #{updated_entries}")
        server(updated_entries, ttl)

      {:ttl, sec} ->
        server(entries, sec)

      :status ->
        IO.inspect("Cache #{entries}")
        server(entries, ttl)

      :stop ->
        IO.inspect("Closing down")
        :ok

      error ->
        IO.inspect("Received unrecognized message: #{error}")
        server(entries, ttl)
    end
  end
end
