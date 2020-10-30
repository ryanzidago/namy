defmodule Namy.Client do
  alias Namy.Logger

  def test(host, res) do
    Logger.log("looking up host #{host}")
    send(res, {:request, self(), host})

    receive do
      {:reply, {:host, pid}} ->
        Logger.log("sending pind ...")
        send(pid, {:ping, self()})

        receive do
          :pong ->
            Logger.log("received pong as a reply")
        after
          1000 ->
            Logger.log("no reply")
        end

      {:reply, :unknown} ->
        Logger.log("unknown host")
        :ok

      error ->
        Logger.log("received strange reply #{error}")
        :ok
    after
      1000 ->
        Logger.log("received no reply from the resolver")
        :ok
    end
  end
end
