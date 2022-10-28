defmodule UeberauthLine.Mixfile do
  use Mix.Project
  @version "0.2.1"

  def project do
    [
      app: :ueberauth_line,
      version: @version,
      name: "Ueberauth LINE Strategy",
      package: package(),
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      mod: {LineLogin.Application, [env: Mix.env()]},
      applications: applications(Mix.env())
    ]
  end

  defp applications(:test), do: applications(:default) ++ [:cowboy, :plug]

  defp applications(_) do
    [
      :logger,
      :jason,
      :ueberauth,
      :typed_struct,
      :mappable,
      :lm_http,
      :httpoison
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ueberauth, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:lm_http, git: "https://github.com/LucidModules/elixir-http", branch: "master"},
      {:typed_struct, "~> 0.2.1"},
      {:mappable, "~> 0.2.0"},
      {:ex_doc, "~> 0.1", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:httpoison, "~> 1.0"},
      # for testing requests
      {:plug_cowboy, "~> 2.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  defp docs do
    [extras: docs_extras(), main: "extra-readme"]
  end

  defp docs_extras do
    ["README.md"]
  end

  defp description do
    "An Uberauth strategy for LINE authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Alex Filatov", "Matt Chad"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/LucidModules/ueberauth_line",
        "Docs" => "https://hexdocs.pm/ueberauth_line"
      }
    ]
  end
end
