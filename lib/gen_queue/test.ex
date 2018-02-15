defmodule GenQueue.Test do
  def setup_queue(gen_queue) do
    set_queue_receiver(gen_queue, :self)
  end

  def reset_queue(gen_queue) do
    set_queue_receiver(gen_queue, nil)
  end

  def setup_global_queue(gen_queue, process_name) when is_atom(process_name) do
    set_queue_receiver(gen_queue, process_name)
    Process.register(self(), process_name)
  end

  def send_item(gen_queue, item) do
    case get_queue_receiver(gen_queue) do
      nil -> nil
      :self -> send(self(), item)
      process_name when is_atom(process_name) -> send(process_name, item)
    end
  end

  defp set_queue_receiver(gen_queue, process_name) when is_atom(process_name) do
    Application.put_env(:gen_queue, gen_queue, process_name)
  end

  defp get_queue_receiver(gen_queue) do
    Application.get_env(:gen_queue, gen_queue)
  end
end
