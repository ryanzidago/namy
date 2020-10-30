defmodule Namy.Host do
  alias Namy.Logger

  def start(name, domain, dns) do
    pid = spawn(__MODULE__, :init, [domain, dns])
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
        Logger.log("received ping from #{from}")
        send(from, :pong)
        host()

      :stop ->
        Logger.log("closing down")
        :ok

      error ->
        Logger.log("received strange message: #{error}")
        host()
    end
  end
end
