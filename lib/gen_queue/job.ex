defmodule GenQueue.Job do
  @type t :: %__MODULE__{
          module: module,
          args: list,
          opts: map
        }

  defstruct module: nil,
            args: [],
            opts: %{}

  @spec new(module, list, map) :: GenQueue.Job.t()
  def new(module, args \\ [], opts \\ %{}) do
    %GenQueue.Job{}
    |> put_module(module)
    |> put_args(args)
    |> put_opts(opts)
  end

  @spec put_module(GenQueue.Job.t(), atom) :: GenQueue.Job.t()
  def put_module(%GenQueue.Job{} = job, module) when is_atom(module) do
    %{job | module: module}
  end

  @spec put_args(GenQueue.Job.t(), list) :: GenQueue.Job.t()
  def put_args(%GenQueue.Job{} = job, args) when is_list(args) do
    %{job | args: args}
  end

  @spec put_opts(GenQueue.Job.t(), map) :: GenQueue.Job.t()
  def put_opts(%GenQueue.Job{opts: old_opts} = job, new_opts) when is_map(new_opts) do
    %{job | opts: Map.merge(new_opts, old_opts)}
  end

  @spec get_opt(GenQueue.Job.t(), atom, any) :: any
  def get_opt(%GenQueue.Job{opts: opts} = job, key, default \\ nil) do
    Map.get(opts, key, default)
  end
end
