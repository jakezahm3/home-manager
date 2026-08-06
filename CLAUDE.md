# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a [Nix Home Manager](https://github.com/nix-community/home-manager) flake managing user `jzahm`'s home environment (packages, shell, and a full NvChad-based Neovim setup). It is not an application codebase — there is no source code to build, lint, or test in the traditional sense. The entire configuration lives in two files:

- `flake.nix` — flake inputs (`nixpkgs`, `home-manager`, `nix4nvchad`) and the `homeConfigurations."jzahm"` output.
- `home.nix` — the actual Home Manager module: packages, fish shell config, and a large embedded NvChad/Neovim configuration (Lua) passed via `programs.nvchad`.

`package.json` / `pnpm-lock.yaml` / `node_modules` only exist to pull in a `neovim` npm package (for Neovim's Node host provider, used by `withNodeJs = true` in `home.nix`) — this is not a JS project and has no scripts to run.

## Common commands

- Apply changes to the live environment: `home-manager switch --flake .#jzahm`
- Check the flake evaluates without applying: `nix flake check`
- Format Nix files (formatter used by the embedded conform.nvim setup): `alejandra home.nix flake.nix`
- Update flake inputs: `nix flake update` (or `nix flake lock --update-input <name>` for a single input)

There are no test suites, linters, or build steps beyond the above — validate changes by running `nix flake check` and/or `home-manager switch` (or `home-manager build` to build without activating).

## Architecture / structure notes

- **Single-module design**: everything is declared inline in `home.nix`; there are no separate `.nix` modules imported besides the external `nix4nvchad` flake module (`inputs.nix4nvchad.homeManagerModules.default`).
- **Neovim config is embedded Lua-in-Nix**: `programs.nvchad` (from `nix4nvchad`) takes Lua source as Nix strings — `extraConfig` (options/LSP/keymaps/formatters), `chadrcConfig` (NvChad's own `chadrc` theme/UI settings), and `extraPlugins` (a lazy.nvim plugin spec table, including `claudecode.nvim` for Claude Code integration inside Neovim, blink.cmp completion with Supermaven, rainbow-delimiters, noice.nvim, etc.). When editing Neovim behavior, find the right section by matching against native NvChad/lazy.nvim conventions, not Nix idioms — the surrounding `''...''` is just a Nix multi-line string.
- LSP servers and formatters for Neovim are provided declaratively via `programs.nvchad.extraPackages` (Nix packages, e.g. `nixd`, `pyright`, `rust-analyzer`) rather than being installed by Mason inside Neovim — Mason is explicitly disabled (`{ "mason-org/mason.nvim", enabled = false }`). New LSP/formatter tooling should be added to `extraPackages` (and wired into `vim.lsp.config`/`vim.lsp.enable` and the `conform.setup` `formatters_by_ft` table in `extraConfig`), not installed from inside Neovim.
- `home.file` symlinks `~/.config/ghostty/config` from an external, unmanaged file at `/home/jzahm/.config/ghostty/config.ghostty` (read via `builtins.readFile`, not tracked in this repo).
- `home.stateVersion` should not be changed casually — per the upstream template comment retained in `home.nix`, it pins Home Manager compatibility behavior, not the installed release version.
