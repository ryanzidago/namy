defmodule Namy.Resolver do
  @moduledoc """
  Resolvers are responsible for helping client find addresses to hosts.
  """
  alias Namy.{Cache, Time, Logger}

  def start(root) do
    pid = spawn_link(__MODULE__, :init, [root])
    Process.register(pid, __MODULE__)
  end

  def stop do
    send(__MODULE__, :stop)
    Process.unregister(__MODULE__)
  end

  def init(root) do
    empty = Cache.new()
    inf = Time.inf()
    cache = Cache.add([], inf, {:dns, root}, empty)
    resolver(cache)
  end

  defp resolver(cache) do
    receive do
      {:request, from, request} ->
        Logger.log("received request #{inspect(request)} from #{inspect(from)}}")
        {reply, updated_cache} = resolve(request, cache)
        send(from, {:reply, reply})
        resolver(updated_cache)

      {:status, from} ->
        Logger.log("Cache #{inspect(cache)}")
        send(from, cache)
        resolver(cache)

      :stop ->
        Logger.log("Closing down #{inspect(__MODULE__)} #{inspect(self())}")
        :ok

      error ->
        Logger.log("received unrecognized message: #{inspect(error)}")
        resolver(cache)
    end
  end

  def resolve(name, cache) do
    Logger.log("resolving #{inspect(name)}")

    case Cache.lookup(name, cache) do
      :unknown ->
        Logger.log("Unknown")
        recursive(name, cache)

      :invalid ->
        Logger.log("Invalid")
        updated_cache = Cache.remove(name, cache)
        recursive(name, updated_cache)

      {:ok, reply} ->
        Logger.log("found #{inspect(reply)}")
        {reply, cache}
    end
  end

  defp recursive([name | domain], cache) do
    Logger.log("Recursive #{inspect(domain)}")

    case resolve(domain, cache) do
      {:unknown, updated_cache} ->
        Logger.log("Unknown")
        {:unknown, updated_cache}

      {{:dns, server}, updated_cache} ->
        send(server, {:request, self(), name})
        Logger.log("Sent #{inspect(name)} to #{inspect(server)}")

        receive do
          {:reply, reply, ttl} ->
            expire = Time.add(Time.now(), ttl)
            {reply, Cache.add([name | domain], expire, reply, updated_cache)}
        end
    end
  end
end
