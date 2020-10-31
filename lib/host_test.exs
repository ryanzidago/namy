defmodule Namy.HostTest do
  use ExUnit.Case
  alias Namy.Host
  import Namy.TestHelpers

  describe "start/3" do
    test "spawns the Namy.Host process with domain and dns; registers its pid under the given name" do
      Host.start(:se, :se, self())
      assert Process.whereis(:se)
      assert :se in Process.registered()
      assert {:register, :se, {:host, _}} = received()
    end
  end

  describe "stop/1" do
    test "stops a Host by its name" do
      Host.start(:se, :se, self())
      host_pid = Process.whereis(:se)

      assert Host.stop(:se)
      refute Process.whereis(:se)
      refute :se in Process.registered()
      refute Process.alive?(host_pid)
    end
  end

  describe "host/0" do
    test "handles {:ping, from} messages by reply :pong to the sender" do
      Host.start(:se, :se, self())
      received()

      send(:se, {:ping, self()})

      assert :pong = received(:pong)
    end

    test "handles :stop messages" do
      Host.start(:se, :se, self())
      assert host_pid = Process.whereis(:se)

      send(host_pid, :stop)
      refute Process.alive?(host_pid)
    end
  end
end
