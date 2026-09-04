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
    pkgs.nodejs
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
    pkgs.python314Packages.pip
    pkgs.python314Packages.fastmcp
    pkgs.rustup
    pkgs.vscode
    pkgs.toolhive
    pkgs.python314Packages.mcp
    pkgs.python314Packages.fastapi-mcp
    pkgs.python314Packages.mcpadapt
    (pkgs.lib.lowPrio pkgs.mcp-server-sequential-thinking)
    pkgs.mcp-server-fetch
    pkgs.mcp-server-filesystem
    pkgs.mcp-language-server
    pkgs.mcp-server-time
    pkgs.dnsutils
    pkgs.lua-language-server
    pkgs.context7-mcp
    pkgs.mcp-proxy
    pkgs.open-websearch
    pkgs.pdf-mcp
    pkgs.dhcpdump
    pkgs.playwright-mcp
    pkgs.terraform-mcp-server
    (pkgs.lib.lowPrio pkgs.mcp-server-memory)
    pkgs.nixd
    pkgs.gcc
    pkgs.traceroute
    pkgs.speedtest-rs
    pkgs.stylua
    pkgs.nixfmt
    pkgs.python314Packages.uv
    pkgs.typesetter
    pkgs.typstPackages.modern-cv
    pkgs.tinymist
    pkgs.prettypst
    pkgs.typst
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ghostscript
    pkgs.ueberzugpp

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
      alias gp="git add -A && sleep 1 && git commit -m "$(uuidgen)" && sleep 3 && git push -u origin main -f" --save
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
      alejandra
      ast-grep
      yaml-language-server
      prettierd
      spectral-language-server
      vscode-langservers-extracted
      pyright
      typescript-language-server
      git
      curl
      black
      shfmt
      jq
      uv
      google-java-format
      python3
      python3Packages.pynvim
      neovim-node-client
      fish-lsp
      texlab
      tex-fmt
      vale-ls
      bacon
      ast-grep
    ];
    extraConfig =
      builtins.replaceStrings
      ["@PYTHON3_HOST_PROG@"]
      [
        "${pkgs.python3.withPackages (p: [p.pynvim])}/bin/python3"
      ]
      (builtins.readFile ./nvim/extraConfig.lua);
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
    "/home/jzahm/.config/helix/languages.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/home-manager/dot-files/languages.toml;
      force = true;
    };
    "/home/jzahm/.config/helix/config.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink /home/jzahm/.config/home-manager/dot-files/config.toml;
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
