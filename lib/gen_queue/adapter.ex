defmodule GenQueue.Adapter do
  @callback handle_push(GenQueue.t(), GenQueue.queue(), any) :: {:ok, any} | {:error, any}

  @callback handle_pop(GenQueue.t(), GenQueue.queue()) :: {:ok, any} | {:error, any}

  @callback handle_flush(GenQueue.t(), GenQueue.queue()) :: {:ok, integer} | {:error, any}
  
  @callback handle_size(GenQueue.t(), GenQueue.queue()) :: {:ok, integer} | {:error, any}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_push(_gen_queue, _queue, _item) do
        {:error, :not_implemented}
      end

      def handle_pop(_gen_queue, _queue) do
        {:error, :not_implemented}
      end

      def handle_flush(_gen_queue, _queue) do
        {:error, :not_implemented}
      end

      def handle_size(_gen_queue, _queue) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
