defmodule Fluxspace.Mixfile do
  use Mix.Project

  def project do
    [app: :fluxspace,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Fluxspace, []},
     applications: [:cowboy, :logger, :gproc, :uuid, :poison]]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:uuid, "~> 1.1"},
      {:gproc, "~> 0.6.1"},
      {:poison, "~> 2.0"},
      {:edeliver, "~> 1.4.2"},
      {:distillery, ">= 0.8.0", warn_missing: false}
    ]
  end
end
