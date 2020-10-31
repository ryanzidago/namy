defmodule Namy.Server do
  @moduledoc """
  Servers are responsible for a domain
  and holds a set of registered hosts and sub-domain servers.
  Servers form a tree structure.
  """
  alias Namy.{Entry, Logger}

  def start do
    pid = spawn_link(__MODULE__, :init, [])
    Process.register(pid, __MODULE__)
  end

  def start(domain, dns) do
    pid = spawn_link(__MODULE__, :init, [domain, dns])
    Process.register(pid, __MODULE__)
  end

  def stop do
    send(__MODULE__, :stop)
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
        Logger.log("Received request #{inspect(name)}")
        reply = Entry.lookup(name, entries)
        send(from, {reply, ttl})
        Logger.log("Sent reply: #{inspect(reply)}")
        server(entries, ttl)

      {:register, name, entry} ->
        updated_entries = Entry.add(name, entry, entries)
        Logger.log("Updated entries: #{inspect(updated_entries)}")
        server(updated_entries, ttl)

      {:deregister, name} ->
        updated_entries = Entry.remove(name, entries)
        Logger.log("Updated entries: #{inspect(updated_entries)}")
        server(updated_entries, ttl)

      {:ttl, ttl} ->
        server(entries, ttl)

      {:status, from} ->
        Logger.log("Cache #{inspect(entries)}")
        send(from, {entries, ttl})
        server(entries, ttl)

      :stop ->
        Logger.log("Closing down")
        Process.exit(self(), :kill)
        :ok

      error ->
        Logger.log("Received unrecognized message: #{inspect(error)}")
        server(entries, ttl)
    end
  end
end
