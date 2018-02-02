defmodule GenQueue.Adapter do
  @callback handle_push(module, GenQueue.Job.t) :: {:ok, GenQueue.Job.t} | {:error, any}

  @callback handle_flush(module, list) :: {:ok, integer} | {:error, any}

  @callback handle_pop(module, list) :: {:ok, GenQueue.Job.t} | {:ok, :nil} | {:error, any}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_push(_caller, _job) do
        {:error, :not_implemented}
      end

      def handle_flush(_caller, _opts \\ [])

      def handle_flush(_caller, _opts) do
        {:error, :not_implemented}
      end

      def handle_pop(_caller, _opts \\ [])
      
      def handle_pop(_caller, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
