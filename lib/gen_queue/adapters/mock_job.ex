defmodule GenQueue.Adapters.MockJob do
  @moduledoc """
  A simple mock job queue implementation.
  """

  use GenQueue.JobAdapter

  def start_link(_gen_queue, _opts) do
    :ignore
  end

  @doc """
  Push a job that will be returned to the current (or globally set) processes
  mailbox.

  Please see `GenQueue.Test` for further details.
  """
  @spec handle_job(gen_queue :: GenQueue.t(), job :: GenQueue.Job.t()) ::
          {:ok, GenQueue.Job.t()} | {:error, any}
  def handle_job(gen_queue, job) do
    GenQueue.Test.send_item(gen_queue, job)
    {:ok, job}
  end
end
