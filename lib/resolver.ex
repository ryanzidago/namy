defmodule Namy.Resolver do
  @moduledoc """
  Resolvers are responsible for helping client find addresses to hosts.
  """
  alias Namy.{Cache, Time}

  def start(root) do
    pid = spawn(__MODULE__, :init, [root])
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
        IO.inspect("#{__MODULE__} #{self()} received request #{request} from #{from}}")
        {reply, updated_cache} = resolve(request, cache)
        send(from, {:reply, reply})
        resolver(updated_cache)

      :status ->
        IO.inspect("Cache #{cache}")
        resolver(cache)

      :stop ->
        IO.inspect("Closing down #{__MODULE__} #{self()}")
        :ok

      error ->
        IO.inspect("#{__MODULE__} #{self()} received unrecognized message: #{error}")
        resolver(cache)
    end
  end

  def resolve(name, cache) do
    IO.inspect("#{__MODULE__} #{self()} resolving #{name}")

    case Cache.lookup(name, cache) do
      :unknown ->
        IO.inspect("Unknown")
        recursive(name, cache)

      :invalid ->
        IO.inspect("Invalid")
        updated_cache = Cache.remove(name, cache)
        recursive(name, updated_cache)

      {:ok, reply} ->
        IO.inspect("#{__MODULE__} #{self()} found #{reply}")
        {reply, cache}
    end
  end

  def recursive([name | domain], cache) do
    IO.inspect("Recursive #{domain}")

    case resolve(domain, cache) do
      {:unknown, updated_cache} ->
        IO.inspect("Unknown")
        {:unknown, updated_cache}

      {{:dns, server}, updated_cache} ->
        send(server, {:request, self(), name})
        IO.inspect("Sent #{name} to #{server}")

        receive do
          {:reply, reply, ttl} ->
            expire = Time.add(Time.now(), ttl)
            {reply, Cache.add([name | domain], expire, reply, updated_cache)}
        end
    end
  end
end
