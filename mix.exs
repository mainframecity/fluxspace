defmodule Fluxspace.Mixfile do
  use Mix.Project

  def project do
    [app: :fluxspace,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Fluxspace, []},
     applications: [:logger, :gen_stage, :gproc]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:gen_stage, "~> 0.4"},
      {:gproc, "~> 0.6.1"}
    ]
  end
end
