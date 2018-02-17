defmodule GenQueue.JobAdapter do

  @callback handle_job(GenQueue.t(), GenQueue.Job.t()) :: {:ok, GenQueue.Job.t()} | {:error, any}

  alias GenQueue.Job

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.JobAdapter
  
      use GenQueue.Adapter

      @doc false
      def handle_push(gen_queue, item, opts) do
        handle_job(gen_queue, Job.new(item, opts))
      end

      @doc false
      def handle_job(_gen_queue, _job) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_pop(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_flush(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      @doc false
      def handle_length(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.JobAdapter
    end
  end
end


