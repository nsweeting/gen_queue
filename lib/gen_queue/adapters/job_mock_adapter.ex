defmodule GenQueue.JobMockAdapter do
  use GenQueue.Adapter

  defguard is_job(job)
           when job |> is_tuple() and job |> tuple_size() == 3 and job |> elem(0) |> is_atom() and
                  job |> elem(1) |> is_list() and job |> elem(2) |> is_map()

  defdelegate start_link(gen_queue, opts), to: GenQueue.SimpleAdapter
  defdelegate handle_pop(gen_queue, queue), to: GenQueue.SimpleAdapter
  defdelegate handle_flush(gen_queue, opts), to: GenQueue.SimpleAdapter
  defdelegate handle_length(gen_queue, opts), to: GenQueue.SimpleAdapter

  def handle_push(gen_queue, queue, job) do
    GenServer.call(gen_queue, {:push, queue, build_job(job)})
  end

  defp build_job(job) when is_job(job) do
    job
  end

  defp build_job(module) when is_atom(module) do
    {module, [], %{}}
  end

  defp build_job({module}) do
    {module, [], %{}} |> build_job()
  end

  defp build_job({module, args}) do
    {module, args, %{}} |> build_job()
  end
end
