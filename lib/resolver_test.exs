defmodule Namy.ResolverTest do
  use ExUnit.Case
  alias Namy.Resolver
  import Namy.TestHelpers

  describe "start/1" do
    test "starts a resolver with a root, and registers the process" do
      Resolver.start(:root)
      resolver_pid = Process.whereis(Resolver)

      assert Process.alive?(resolver_pid)
      assert Resolver in Process.registered()
    end
  end

  describe "stop" do
    test "stops the Resolver and unregisters it" do
      Resolver.start(:root)
      resolver_pid = Process.whereis(Resolver)

      Resolver.stop()

      refute Resolver not in Process.registered()
      refute Process.alive?(resolver_pid)
    end
  end

  describe "resolver/1" do
    test "handles {:request, from, request} messages" do
      Resolver.start(:root)
      resolver_pid = Process.whereis(Resolver)
      send(resolver_pid, {:request, self(), :se})
    end

    test "handles :status messages" do
      Resolver.start(:root)
      received()
      resolver_pid = Process.whereis(Resolver)
      send(resolver_pid, {:status, self()})

      assert [] = received([])
    end

    test "handles :stop messages" do
      Resolver.start(:root)
      received()
      resolver_pid = Process.whereis(Resolver)
      send(resolver_pid, :stop)

      assert Resolver not in Process.registered()
      refute Process.alive?(resolver_pid)
    end
  end
end
