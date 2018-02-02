defmodule GenQueue.Job do
  @type t :: %__MODULE__{
    enqueuer: module,
    module:   module,
    args:     list,
    opts:     list,
    meta:     map
  }

  defstruct [
    enqueuer: nil,
    module:   nil,
    args:     [],
    opts:     [],
    meta:     %{}
  ]

  @spec new(module, list, list, map) :: GenQueue.Job.t
  def new(module, args \\ [], opts \\ [], meta \\ %{}) do
    %GenQueue.Job{}
    |> put_module(module)
    |> put_args(args)
    |> put_opts(opts)
    |> put_meta(meta)
  end

  @spec put_enqueuer(GenQueue.Job.t, atom) :: GenQueue.Job.t
  def put_enqueuer(%GenQueue.Job{} = job, enqueuer) when is_atom(enqueuer) do
    %{job | enqueuer: enqueuer}
  end

  @spec put_module(GenQueue.Job.t, atom) :: GenQueue.Job.t
  def put_module(%GenQueue.Job{} = job, module) when is_atom(module) do
    %{job | module: module}
  end

  @spec put_args(GenQueue.Job.t, list) :: GenQueue.Job.t
  def put_args(%GenQueue.Job{} = job, args) when is_list(args) do
    %{job | args: args}
  end

  @spec put_opts(GenQueue.Job.t, list) :: GenQueue.Job.t
  def put_opts(%GenQueue.Job{} = job, opts) when is_list(opts) do
    %{job | opts: opts}
  end

  @spec put_meta(GenQueue.Job.t, map) :: GenQueue.Job.t
  def put_meta(%GenQueue.Job{} = job, meta) when is_map(meta) do
    %{job | meta: meta}
  end

  @spec assign(GenQueue.Job.t, atom, any) :: GenQueue.Job.t
  def assign(%GenQueue.Job{meta: meta} = job, key, value) do
    %{job | meta: Map.put(meta, key, value)}
  end
end
