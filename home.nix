{
  config,
  inputs,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jzahm";
  home.homeDirectory = "/home/jzahm";

  imports = [inputs.nix4nvchad.homeManagerModules.default];
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.yazi
    pkgs.fish
    pkgs.tealdeer
    pkgs.ghostty
    pkgs.corepack_24
    pkgs.python3
    pkgs.wl-clipboard
    pkgs.claude-code
    pkgs.kitty
    pkgs.neovide
    pkgs.eyedropper
    pkgs.mcp-nixos
    pkgs.python313Packages.pip
    pkgs.python313Packages.fastmcp
    pkgs.cargo
    pkgs.rustc
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx EDITOR "nvim"
      set -gx VISUAL "nvim"

      if test -f /home/jzahm/.config/home-manager/mcp/.secrets
        source /home/jzahm/.config/home-manager/mcp/.secrets
      end
    '';
  };

  programs.nvchad = {
    backup = false;
    enable = true;
    hm-activation = true;
    neovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
      withNodeJs = true;
      withPython3 = true;
    };

    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      stylua
      bash-language-server
      nixd
      alejandra
      ast-grep
      yaml-language-server
      prettierd
      spectral-language-server
      vscode-langservers-extracted
      pyright
      rust-analyzer
      typescript-language-server
      rustc
      cargo
      git
      curl
      black
      shfmt
      rustfmt
      jq
      nodejs
      uv
      google-java-format
      python3
      python3Packages.pynvim
      neovim-node-client
      mcp-server-memory
      fish-lsp
      texlab
      tex-fmt
      vale-ls
      bacon
      ast-grep
    ];
    extraConfig = builtins.replaceStrings ["@PYTHON3_HOST_PROG@"] [
      "${pkgs.python3.withPackages (p: [p.pynvim])}/bin/python3"
    ] (builtins.readFile ./nvim/extraConfig.lua);
    chadrcConfig = builtins.readFile ./nvim/chadrc.lua;
    extraPlugins = builtins.readFile ./nvim/plugins.lua;
  };

  # nixpkgs' cargo ships a vendor fish completion that shells out to
  # `CARGO_COMPLETE=fish cargo -- ...` (cargo's built-in dynamic completion
  # engine), which currently panics on invocation (cli.rs:747, NotFound) and
  # dumps a Rust backtrace to the terminal on every Tab press. Fish loads
  # completions from ~/.config/fish/completions before any vendor_completions.d
  # dir and stops at the first match, so this static list shadows the broken
  # one.
  xdg.configFile."fish/completions/cargo.fish".text = ''
    set -l cargo_subcommands \
      build\t'Compile the current package' \
      check\t'Analyze the current package and report errors' \
      clean\t'Remove the target directory' \
      doc\t'Build this package\'s and its dependencies\' documentation' \
      new\t'Create a new cargo package' \
      init\t'Create a new cargo package in an existing directory' \
      add\t'Add dependencies to a manifest file' \
      remove\t'Remove dependencies from a manifest file' \
      run\t'Run a binary or example of the local package' \
      test\t'Run the tests' \
      bench\t'Run the benchmarks' \
      update\t'Update dependencies listed in Cargo.lock' \
      search\t'Search registry for crates' \
      publish\t'Package and upload this package to the registry' \
      install\t'Install a Rust binary' \
      uninstall\t'Uninstall a Rust binary' \
      tree\t'Display a tree visualization of a dependency graph' \
      vendor\t'Vendor all dependencies locally' \
      fmt\t'Format Rust code' \
      clippy\t'Run clippy lints' \
      fix\t'Automatically fix lint warnings' \
      metadata\t'Output the resolved dependencies of a package' \
      generate-lockfile\t'Generate Cargo.lock' \
      locate-project\t'Print a JSON representation of a Cargo.toml location' \
      login\t'Log in to a registry' \
      logout\t'Remove an API token from the registry locally' \
      owner\t'Manage the owners of a crate on the registry' \
      package\t'Assemble the local package into a distributable tarball' \
      pkgid\t'Print a fully qualified package specification' \
      report\t'Generate and display various kinds of reports' \
      rustc\t'Compile the current package, and pass extra options to the compiler' \
      rustdoc\t'Build a package'"'"'s documentation, using specified custom flags' \
      verify-project\t'Check correctness of crate manifest' \
      yank\t'Remove a pushed crate from the index'

    complete -c cargo -f
    complete -c cargo -n __fish_use_subcommand -a "$cargo_subcommands"

    complete -c cargo -l release -d 'Build artifacts in release mode'
    complete -c cargo -l verbose -s v -d 'Use verbose output'
    complete -c cargo -l quiet -s q -d 'Do not print cargo log messages'
    complete -c cargo -l offline -d 'Run without accessing the network'
    complete -c cargo -l locked -d 'Assert that Cargo.lock will remain unchanged'
    complete -c cargo -l frozen -d 'Equivalent to --locked and --offline'
    complete -c cargo -l help -s h -d 'Print help'
    complete -c cargo -l version -s V -d 'Print version info and exit'
    complete -c cargo -l list -d 'List installed commands'
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Ghostty terminal configuration
    "/home/jzahm/.config/ghostty/config.ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/home-manager/dot-files/config.ghostty;
      force = true;
    }; # Kitty terminal configuration
    "/home/jzahm/.config/kitty/kitty.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/home-manager/dot-files/kitty.conf;
      force = true;
    };
    ".mcp.json" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/home-manager/mcp/mcp-nixos.json;
      force = true;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jzahm/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
