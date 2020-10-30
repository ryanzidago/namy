defmodule Namy.ServerTest do
  use ExUnit.Case
  alias Namy.Server

  describe "start/0" do
    test "spawns and registers a process under the name Namy.Server" do
      assert Server.start()
      assert Process.whereis(Server)
    end
  end

  describe "start/2" do
    test "spawns and registers a process under the name Namy.Server and receives a message shortly after" do
      assert Server.start(:se, self())
      assert server_pid = Process.whereis(Server)
      assert {:register, :se, {:dns, ^server_pid}} = received()
    end
  end

  describe "stop/0" do
    test "stops the Namy.Server and unregister it" do
      Server.start()
      server_pid = Process.whereis(Server)

      assert Server.stop()
      refute Process.alive?(server_pid)
      assert Server not in Process.registered()
    end
  end

  describe "server/2" do
    test "handles :request messages and sends back a message" do
      Server.start()
      server_pid = Process.whereis(Server)

      send(server_pid, {:register, :se, self()})
      send(server_pid, {:request, self(), :se})

      expected = {{:se, self()}, 0}
      assert expected == received(expected)
    end

    test "handles :request messages and sends back a message when server is started with params" do
      Server.start(:se, self())
      server_pid = Process.whereis(Server)
      send(server_pid, {:request, self(), :se})

      assert {:register, :se, {:dns, _pid}} = received()
    end

    test "handles :register messages" do
      Server.start()

      server_pid = Process.whereis(Server)

      send(server_pid, {:register, :se, self()})
      send(server_pid, {:request, self(), :se})

      expected = {{:se, self()}, 0}
      assert expected == received(expected)
    end

    test "handles :deregister messages by removing the entry from the list of entries" do
      Server.start()
      server_pid = Process.whereis(Server)

      send(server_pid, {:register, :se, :"root@123.456.789"})
      send(server_pid, {:deregister, :se})
      send(server_pid, {:request, self(), :se})

      assert {:unknown, _ttl} = received()
    end

    test "handles :ttl messages" do
      Server.start()
      server_pid = Process.whereis(Server)

      send(server_pid, {:ttl, 10_000})
      send(server_pid, {:status, self()})

      expected = {[], 10_000}
      assert expected == received(expected)
    end

    test "handles :status messages" do
      Server.start()
      server_pid = Process.whereis(Server)

      send(server_pid, {:status, self()})

      expected = {[], 0}
      assert expected == received(expected)
    end

    test "handles :stop messages" do
      Server.start()
      server_pid = Process.whereis(Server)
      send(server_pid, :stop)

      refute Process.alive?(server_pid)
    end
  end

  defp received do
    receive do
      message -> message
    after
      500 -> nil
    end
  end

  defp received(expected) do
    receive do
      message when message == expected -> message
      message -> message
    after
      500 -> nil
    end
  end
end
