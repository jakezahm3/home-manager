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
    '';
  };

  programs.nvchad = {
    backup = false;
    enable = true;
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
      vscode
    ];
    extraConfig = builtins.replaceStrings ["@PYTHON3_HOST_PROG@"] [
      "${pkgs.python3.withPackages (p: [p.pynvim])}/bin/python3"
    ] (builtins.readFile ./nvim/extraConfig.lua);
    chadrcConfig = builtins.readFile ./nvim/chadrc.lua;
    extraPlugins = builtins.readFile ./nvim/plugins.lua;
  };

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
    ".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/ghostty/config.ghostty;
    # Kitty terminal configuration
    ".config/kitty/kitty.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/kitty/kitty.conf.kitty;
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
