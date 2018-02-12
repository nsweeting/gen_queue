defmodule GenQueue.Adapters.SimpleServer do
  use GenServer

  def start_link(caller, _opts) do
    GenServer.start_link(__MODULE__, %{}, name: caller)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:push, queue_name, item}, _from, queues) do
    {_, queues} =
      Map.get_and_update(queues, queue_name, fn
        nil -> {nil, :queue.in(item, :queue.new())}
        queue -> {nil, :queue.in(item, queue)}
      end)

    {:reply, {:ok, item}, queues}
  end

  def handle_call({:flush, queue_name}, _from, queues) do
    queue_size =
      case Map.get(queues, queue_name) do
        nil -> 0
        queue -> :queue.len(queue)
      end

    queues = Map.put(queues, queue_name, :queue.new())
    {:reply, {:ok, queue_size}, queues}
  end

  def handle_call({:pop, queue_name}, _from, queues) do
    {item, queues} =
      Map.get_and_update(queues, queue_name, fn
        nil ->
          {nil, :queue.new()}

        queue ->
          case :queue.out(queue) do
            {{:value, item}, new_queue} -> {item, new_queue}
            {:empty, new_queue} -> {nil, new_queue}
          end
      end)

    {:reply, {:ok, item}, queues}
  end
end
