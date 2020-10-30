defmodule Namy.Host do
  def start(name, domain, dns) do
    pid = spawn(__MODULE__, :init, [domain, dns])
    Process.register(pid, __MODULE__)
  end

  def stop(name) do
    send(name, :stop)
    Process.unregister(__MODULE__)
  end

  def init(domain, dns) do
    send(dns, {:register, domain, {:host, self()}})
    host()
  end

  defp host do
    receive do
      {:ping, from} ->
        IO.inspect("#{__MODULE__} #{self()} received ping from #{from}")
        send(from, :pong)
        host()

      :stop ->
        IO.inspect("#{__MODULE__} #{self()} closing down")
        :ok

      error ->
        IO.inspect("#{__MODULE__} #{self()} received strange message: #{error}")
        host()
    end
  end
end
