defmodule GenQueue.Adapters.JobMock do
  use GenQueue.Adapter

  defguard is_job(job)
    when is_tuple(job)
    and tuple_size(job) == 3
    and job |> elem(0) |> is_atom()
    and job |> elem(1) |> is_list()
    and job |> elem(2) |> is_map()

  defdelegate start_link(gen_queue, opts), to: GenQueue.Adapters.Simple
  defdelegate handle_pop(gen_queue, queue), to: GenQueue.Adapters.Simple
  defdelegate handle_flush(gen_queue, opts), to: GenQueue.Adapters.Simple
  defdelegate handle_length(gen_queue, opts), to: GenQueue.Adapters.Simple

  def handle_push(caller, queue, job) do
    GenServer.call(caller, {:push, queue, build_job(job)})
  end

  defp build_job(job) when is_job(job), do: job

  defp build_job({module}), do: {module, [], %{}} |> build_job()

  defp build_job({module, args}), do: {module, args, %{}} |> build_job()
end
