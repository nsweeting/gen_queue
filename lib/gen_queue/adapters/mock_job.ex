defmodule GenQueue.Adapters.MockJob do
  @moduledoc """
  A simple 
  """

  use GenQueue.JobAdapter

  def start_link(_gen_queue, _opts) do
    :ignore
  end

  def handle_job(gen_queue, job) do
    GenQueue.Test.send_item(gen_queue, job)
    {:ok, job}
  end
end
