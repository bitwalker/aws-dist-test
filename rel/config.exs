~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()


environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"l];J<ek/U*.zxTecvnL(~sP~X.H)rcBLwOUB[3ZGV;il6xk;6Xz|x;R4ev!<;u1e"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"niacks]vOyv&k6[sBF]y4}xxHn|vC6~@{kTh5[P>4>2dGG{F:cpxKE7G78c%JWtU"

  # We use an extra config evaluated solely at runtime
  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]}
  ]

  # We source control our service file, overlay it into the release tarball
  # and it is expected that this path will be symlinked to the appropriate systemd service
  # directory on the target
  set overlays: [
    {:mkdir, "etc"},
    {:template, "rel/etc/<%= release_name %>.service", "etc/<%= release_name %>.service"},
    {:copy, "rel/etc/<%= release_name %>.config.exs", "etc/config.exs"}
  ]
end

release :engine do
  set version: current_version(:engine)
  set applications: [
    :engine,
    :runtime_tools,
  ]

  # Custom vm.args
  set vm_args: "rel/engine.vm.args"

  # Custom commands
  set commands: [
    migrate: "rel/commands/migrate.sh"
  ]
end

release :web do
  set version: current_version(:web)
  set applications: [
    :web,
    :runtime_tools
  ]

  # Custom vm.args
  set vm_args: "rel/web.vm.args"
end
