{
  # Every flake needs a `description`. It's just metadata — shown by
  # `nix flake show`/`nix flake metadata` — and has no effect on evaluation.
  description = "Home Manager configuration of jzahm";

  # `inputs` declares every external flake this flake depends on. Think of it
  # like a lockfile's "dependencies" section, but each entry is itself a
  # flake with its own inputs/outputs. Nix resolves this whole graph and
  # pins every input's exact commit in `flake.lock` — that lock file (not
  # this one) is what makes builds reproducible across machines and time.
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    #
    # `nixpkgs` is the big package repository (nearly everything installed
    # below, e.g. via `home.packages`, ultimately comes from here). Pointing
    # at the `nixpkgs-unstable` branch of the official GitHub repo means
    # "track the rolling, most-up-to-date package set" rather than a
    # versioned stable release like `nixos-24.11`.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Not following our nixpkgs here: this flake's own claude-desktop.nix
    # references `nodePackages.asar`, which our rolling nixpkgs-unstable
    # has since removed. Let it use its own pinned, compatible nixpkgs.
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    home-manager = {
      url = "github:nix-community/home-manager";
      # `inputs.nixpkgs.follows = "nixpkgs"` tells the home-manager flake:
      # "don't fetch your own copy of nixpkgs — reuse the exact `nixpkgs`
      # input I (this flake) already resolved above." Without `follows`,
      # home-manager would pin its *own* nixpkgs revision, and you'd end up
      # with two different copies of nixpkgs in the closure — more disk
      # space, longer evaluation, and subtle bugs from mismatched package
      # sets. `follows` is how flakes de-duplicate shared dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      # Same deduplication trick for the third-party module that provides
      # `programs.nvchad` (used heavily in home.nix for the Neovim setup).
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `outputs` is a function: it receives the resolved inputs (each input
  # attribute here is itself that dependency's *own* `outputs` result) and
  # returns an attribute set describing what this flake provides — packages,
  # NixOS modules, dev shells, or in this case a `homeConfigurations` output
  # consumed by the `home-manager` CLI.
  outputs = {
    # `self` refers to this flake itself (its own outputs/store path) —
    # not used directly here, but always implicitly available.
    self,
    # These names must match keys declared in `inputs` above; Nix binds
    # each one to that input flake's own `outputs`.
    nixpkgs,
    home-manager,
    # `...` collects any remaining inputs not explicitly named (here,
    # that's `nix4nvchad`) so the function doesn't error on extra args.
    ...
    # `@inputs` captures the *entire* original argument set (including the
    # ones destructured above) under the name `inputs`. This lets home.nix
    # get access to `nix4nvchad` via `extraSpecialArgs = { inherit inputs; }`
    # below, even though `nix4nvchad` wasn't pattern-matched by name here.
  } @ inputs: let
    # Flakes are evaluated per-system for reproducibility — there's no
    # implicit "current machine" the way classic Nix expressions have.
    # This hardcodes the target to 64-bit Linux; on NixOS/multi-arch
    # setups you'd typically parameterize this instead.
    system = "x86_64-linux";
    # `nixpkgs.legacyPackages.<system>` is how flakes expose the full,
    # familiar `pkgs` set (all packages + `pkgs.lib` etc.) for a given
    # system — "legacyPackages" because nixpkgs predates the flake output
    # schema and exposes its huge attribute set under that name rather
    # than the more restrictive `packages` output.
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # This is the actual flake output that `home-manager switch --flake
    # .#jzahm` looks up: `homeConfigurations.<name>`. The `.#jzahm` in
    # that command is "this flake, output `jzahm`".
    homeConfigurations."jzahm" = home-manager.lib.homeManagerConfiguration {
      # Shorthand for `pkgs = pkgs;` — pass the evaluated package set
      # (for the system chosen above) into the Home Manager configuration.
      inherit pkgs;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      #
      # `extraSpecialArgs` injects extra arguments into every module's
      # function signature (alongside the standard `config`, `lib`,
      # `pkgs`, etc.). Here it forwards the whole `inputs` set — that's
      # how home.nix can reach `inputs.nix4nvchad.homeManagerModules.default`
      # to pull in the NvChad module.
      extraSpecialArgs = {inherit inputs;};
      # `modules` is the list of Home Manager modules to evaluate together,
      # analogous to NixOS's `imports`. Right now it's just the one file —
      # this repo deliberately keeps everything in a single module rather
      # than splitting into multiple imported `.nix` files.
      modules = [./home.nix];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
