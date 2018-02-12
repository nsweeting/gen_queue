defmodule GenQueue.Adapter do
  @callback handle_push(atom, binary, any) :: {:ok, any} | {:error, any}

  @callback handle_pop(atom, binary) :: {:ok, any} | {:error, any}

  @callback handle_flush(atom, binary) :: {:ok, integer} | {:error, any}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_push(_enqueuer, _queue, _item) do
        {:error, :not_implemented}
      end

      def handle_pop(_enqueuer, _queue) do
        {:error, :not_implemented}
      end

      def handle_flush(_enqueuer, _queue) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
