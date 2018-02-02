defmodule GenQueue.Adapter do
  @callback handle_enqueue(module, GenQueue.Job.t) :: {:ok, GenQueue.Job.t} | {:error, any}

  @callback handle_flush(module, list) :: {:ok, integer} | {:error, any}

  @callback handle_last(module, list) :: {:ok, GenQueue.Job.t} | {:error, :no_job} | {:error, :not_implemented}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_enqueue(_caller, _job) do
        {:error, :not_implemented}
      end

      def handle_flush(_caller, _opts \\ [])

      def handle_flush(_caller, _opts) do
        {:error, :not_implemented}
      end

      def handle_last_job(_caller, _opts \\ [])
      
      def handle_last_job(_caller, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
