defmodule GenQueue.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [
      app: :gen_queue,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Job queue wrapper with adapter support for Elixir
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links:  %{"GitHub" => "https://github.com/nsweeting/gen_queue"}
    ]
  end

  defp docs do
    [
      source_url: "https://github.com/nsweeting/gen_queue"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end
