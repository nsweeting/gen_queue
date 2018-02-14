defmodule GenQueue.Adapter do
  @callback handle_push(GenQueue.t(), any, list) :: {:ok, any} | {:error, any}

  @callback handle_pop(GenQueue.t(), list) :: {:ok, any} | {:error, any}

  @callback handle_flush(GenQueue.t(), list) :: {:ok, integer} | {:error, any}
  
  @callback handle_size(GenQueue.t(), list) :: {:ok, integer} | {:error, any}

  @type t :: module

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour GenQueue.Adapter

      def handle_push(_gen_queue, _item, _opts) do
        {:error, :not_implemented}
      end

      def handle_pop(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      def handle_flush(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      def handle_size(_gen_queue, _opts) do
        {:error, :not_implemented}
      end

      defoverridable GenQueue.Adapter
    end
  end
end
