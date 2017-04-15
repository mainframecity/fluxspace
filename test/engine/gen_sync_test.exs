alias Fluxspace.GenSync

defmodule Fluxspace.GenSyncTest do
  use ExUnit.Case

  defmodule CompilationTestHandler do
    use GenSync
  end

  defmodule TestHandler do
    use GenSync

    def init({:state, %{} = state}, test_pid) do
      {:ok, {:state, Map.merge(state, %{pid: test_pid, test: 1})}}
    end

    def handle_event(:bar, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :bar})
      {:ok, state}
    end

    def handle_event(:set, {:state, %{pid: test_pid} = state}) do
      send(test_pid, {:got, :set})
      {:ok, {:state, %{state | test: 2}}}
    end

    def handle_event(:become, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :become})
      {:become, TestHandler2, {:cool, test_pid}, state}
    end

    def handle_event(:stop, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :stop})
      {:stop, :some_reason, state}
    end

    def handle_event(:stop_process, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :stop_process})
      {:stop_process, :normal, state} # suppress warnings/errors by using 'normal'
    end

    def handle_change({:state, %{test: 1}}, {:state, %{pid: test_pid, test: 2}}) do
      send(test_pid, {:got, :change})
      :ok
    end

    def handle_call(:calling, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :call})
      {:ok, :call_reply, state}
    end

    def handle_call(:call_set, {:state, %{pid: test_pid} = state}) do
      send(test_pid, {:got, :call_set})
      {:ok, :call_reply, {:state, %{state | test: 2}}}
    end

    def terminate(reason, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :terminate, reason})
      {:ok, state}
    end
  end

  defmodule TestHandler2 do
    use GenSync

    def init({:state, %{pid: test_pid} = state}, {:cool, test_pid}) do
      {:ok, {:state, Map.merge(state, %{cool: test_pid, test: 3})}}
    end

    def handle_event(:bar2, {:state, %{pid: test_pid, cool: test_pid, test: 3}} = state) do
      send(test_pid, {:got, :bar2})
      {:ok, state}
    end

    def terminate(_reason, {:state, %{pid: test_pid}} = state) do
      send(test_pid, {:got, :terminate2})
      {:ok, state}
    end
  end

  setup do
    {:ok, pid} = GenSync.start_link({:state, %{}})
    GenSync.put_handler(pid, TestHandler, self())
    {:ok, [handler: pid]}
  end

  test "handler adding and reacts to event", %{handler: pid} do
    assert GenSync.has_handler?(pid, TestHandler) == true

    # Send a normal event
    GenSync.notify(pid, :bar)
    assert_receive {:got, :bar}

    # Send unhandled event, no handler should reply
    GenSync.notify(pid, :noop)
    refute_receive _

    # Send a normal event again
    GenSync.notify(pid, :bar)
    assert_receive {:got, :bar}
  end

  test "State manipulation from handler with call", %{handler: pid} do
    GenSync.call(pid, TestHandler, :call_set)
    assert_receive {:got, :call_set}
    assert_receive {:got, :change}
  end

  test "Can remove handler", %{handler: pid} do
    assert GenSync.has_handler?(pid, TestHandler) == true
    :ok = GenSync.remove_handler(pid, TestHandler)
    assert GenSync.has_handler?(pid, TestHandler) == false
  end

  test "Stopping a handler is handled", %{handler: pid} do
    assert GenSync.has_handler?(pid, TestHandler) == true

    # Sending a stop should stop this handler
    GenSync.notify(pid, :stop)
    assert_receive {:got, :stop}
    assert_receive {:got, :terminate, :some_reason}

    # And now sending a message will not be handled
    assert GenSync.has_handler?(pid, TestHandler) == false
    GenSync.notify(pid, :bar)
    refute_receive _

    # And then we can add the handler back
    GenSync.put_handler(pid, TestHandler, self())
    assert GenSync.has_handler?(pid, TestHandler) == true
    GenSync.notify(pid, :bar)
    assert_receive {:got, :bar}
  end


  test "handler terminated when GenSync terminates", %{handler: pid} do
    Process.exit(pid, :normal)
    assert_receive {:got, :terminate, :normal}

    # send normal event, now shouldnt respond
    GenSync.notify(pid, :bar)
    refute_receive {:got, :bar}
  end
end
