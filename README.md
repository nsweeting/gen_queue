# GenQueue

GenQueue is a specification for queues.

This project currently provides the following functionality:

  * `GenQueue` ([docs](https://hexdocs.pm/gen_queue/GenQueue.html)) - a behaviour for queues

  * `GenQueue.Adapter` ([docs](https://hexdocs.pm/gen_queue/GenQueue.Adapter.html)) - a behaviour for implementing adapters for a `GenQueue`


## Installation

The package can be installed by adding `gen_queue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue, "~> 0.1.0"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue) for additional documentation.

## Adapters

The true functionality of `GenQueue` comes with use of its adapters. Currently, the following
adapters are supported.

  * [GenQueue Exq](https://github.com/nsweeting/gen_queue_exq) - Redis-backed job queue.
  * [GenQueue TaskBunny](https://github.com/nsweeting/gen_queue_task_bunny) - RabbitMQ-backed job queue.
  * [GenQueue Verk](https://github.com/nsweeting/gen_queue_verk) - Redis-backed job queue.
  * [GenQueue OPQ](https://github.com/nsweeting/gen_queue_opq) - GenStage-backed job queue.

More adapters are always welcome!
