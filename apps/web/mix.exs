defmodule Example.Mixfile do
  use Mix.Project

  def project do
    [
      app: :web,
      version: "0.1.0",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(Mix.env)
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Example.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run engine alongside web in dev and test
  defp deps(env) when env in [:dev, :test] do
    [{:engine, in_umbrella: true} | deps(:prod)]
  end
  # In prod, engine will run as a separate release
  defp deps(_) do
    [
      {:services, in_umbrella: true},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:gettext, "~> 0.11"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      compile: ["compile", &compile_assets/1],
      clean: ["clean", &clean_assets/1]
    ]
  end

  defp compile_assets(_args) do
    assets_dir = Path.join([Application.app_dir(:web, "priv"), "..", "assets"])
    static_dir = Path.join(Application.app_dir(:web, "priv"), "static")
    File.mkdir_p!(Path.join(static_dir, "js"))
    File.mkdir_p!(Path.join(static_dir, "css"))
    for item <- ["js", "css", "favicon.ico", "robots.txt"] do
      File.cp_r!(Path.join(assets_dir, item), Path.join(static_dir, item))
    end
  end

  defp clean_assets(_args) do
    static_dir = Path.join(Application.app_dir(:web, "priv"), "static")
    for item <- ["js", "css", "favicon.ico", "robots.txt"] do
      File.rm_rf!(Path.join(static_dir, item))
    end
  end
end
