defmodule Namy.Client do
  def test(host, res) do
    IO.inspect("#{__MODULE__} #{self()} looking up host #{host}")
    send(res, {:request, self(), host})

    receive do
      {:reply, {:host, pid}} ->
        IO.inspect("#{__MODULE__} #{self()} sending pind ...")
        send(pid, {:ping, self()})

        receive do
          :pong ->
            IO.inspect("#{__MODULE__} #{self()} received pong as a reply")
        after
          1000 ->
            IO.inspect("#{__MODULE__} #{self()} no reply")
        end

      {:reply, :unknown} ->
        IO.inspect("#{__MODULE__} #{self()} unknown host")
        :ok

      error ->
        IO.inspect("#{__MODULE__} #{self()} received strange reply #{error}")
        :ok
    after
      1000 ->
        IO.inspect("#{__MODULE__} #{self()} received no reply from the resolver")
        :ok
    end
  end
end
