defmodule Namy.Host do
  alias Namy.Logger

  @moduledoc """
  Namy.Host.start(:www, :www, {:server, :"kth@123.456.789"})

  # => send({:server, :"kth@123.456.789"}, {:register, :www, {:host, self()}})
  """

  def start(name, domain, dns) do
    pid = spawn_link(__MODULE__, :init, [domain, dns])
    Process.register(pid, name)
  end

  def stop(name) do
    send(name, :stop)
    Process.unregister(name)
  end

  def init(domain, dns) do
    send(dns, {:register, domain, {:host, self()}})
    host()
  end

  defp host do
    receive do
      {:ping, from} ->
        Logger.log("received ping from #{inspect(from)}")
        send(from, :pong)
        host()

      :stop ->
        Logger.log("closing down")
        Process.exit(self(), :kill)
        :ok

      error ->
        Logger.log("received strange message: #{inspect(error)}")
        host()
    end
  end
end
