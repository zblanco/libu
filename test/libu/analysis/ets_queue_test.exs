defmodule Libu.EtsQueueTest do
  use ExUnit.Case
  alias Libu.Analysis.EtsQueue


  describe "EtsQueue: " do
    test "new/0 creates an %EtsQueue{} struct with a tid" do
      queue = EtsQueue.new()

      assert queue.tid != nil
    end

    test "new/1 creates an %EtsQueue{} struct with a tid and length" do
      queue = EtsQueue.new(10)

      assert queue.tid != nil
      assert queue.length == 10
    end

    test "get/1 fetches the next item in the queue" do
      queue = EtsQueue.new
      :ok = EtsQueue.put(queue, %{name: "bob"})
      :ok = EtsQueue.put(queue, %{name: "alice"})

      {:ok, item} = EtsQueue.get(queue)

      assert item.name == "bob"
    end

    test "get/1 returns an error if the queue is empty" do
      queue = EtsQueue.new

      assert EtsQueue.get(queue) == {:error, :empty_queue}
    end

    test "get/2 fetches a given amount from the queue" do
      queue = EtsQueue.new
      :ok = EtsQueue.put(queue, %{name: "bob"})
      :ok = EtsQueue.put(queue, %{name: "alice"})
      :ok = EtsQueue.put(queue, %{name: "sam"})
      :ok = EtsQueue.put(queue, %{name: "kevin"})

      {:ok, items} = EtsQueue.get(queue, 3)
      assert length(items) == 3
    end

    test "get/2 fetches everything left in queue if amount requested exceeds size" do
      queue = EtsQueue.new
      :ok = EtsQueue.put(queue, %{name: "bob"})
      :ok = EtsQueue.put(queue, %{name: "alice"})

      {:ok, items} = EtsQueue.get(queue, 4)
      assert length(items) == 2
    end

    test "get/2 returns an error if the queue is empty" do
      queue = EtsQueue.new

      assert EtsQueue.get(queue, 4) == {:error, :empty_queue}
    end

    test "length/1 provides a count of how many items are in the queue" do
      queue = EtsQueue.new
      :ok = EtsQueue.put(queue, %{name: "bob"})
      :ok = EtsQueue.put(queue, %{name: "alice"})

      size = EtsQueue.length(queue)
      assert size == 2
    end

    test "get_all/1 non-destructively fetches a dump of all items in the queue including their order" do
      queue = EtsQueue.new
      :ok = EtsQueue.put(queue, %{name: "bob"})
      :ok = EtsQueue.put(queue, %{name: "alice"})

      dump = EtsQueue.get_all(queue)
      assert dump == [{0, %{name: "bob"}}, {1, %{name: "alice"}}]

      size = EtsQueue.length(queue)
      assert size == 2
    end
  end
end
