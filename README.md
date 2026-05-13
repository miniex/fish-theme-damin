# fish-theme-damin

> Small, opinionated fish prompt. Florette (`✿`) left, heart bullet (`❥`) right, two-color palette (`#98ABCC` / `#E890B0`). Pure dingbats — no Nerd Font required. Works with [Fisher][fisher] and [Oh My Fish][omf].

## Preview

Git workflow — counts, op state, conflict, duration, exit code. Past prompts collapse to `✿` after Enter:

![git workflow](assets/preview-0.gif)

Language detection, env (`.venv` / `nix`), vi mode, custom segment:

![lang + env + vi + custom segment](assets/preview-1.gif)

Cloud + DevOps — `aws:<profile>@<region>` / `k8s:<ctx>/<ns>` / `tf:<workspace>` / `pulumi:<stack>`:

![cloud + devops](assets/preview-2.gif)

## Install

Requires **fish ≥ 3.7** (for the `path mtime` builtin).

**Fisher**

```fish
fisher install miniex/fish-theme-damin
```

**Oh My Fish**

```fish
omf install https://github.com/miniex/fish-theme-damin
omf theme fish-theme-damin
```

**Local hacking — Fisher**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
fisher install (pwd)/fish-theme-damin
```

**Local hacking — Oh My Fish**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
ln -sfn (pwd)/fish-theme-damin ~/.local/share/omf/themes/fish-theme-damin
omf theme fish-theme-damin
```

## Highlights

- **Fast** — ~0.5 ms/prompt. In-memory PWD memos on lang/git/cwd skip disk i/o after the first prompt. Async refresh forks a ~3 KB core. Cloud/devops/battery/jj autoload only when enabled. `-uno` opt-out for monorepos
- **git / jj** — counts (`X2 ?2 ✗3 ✓1 ⇡N`), op state, `wt:<name>`, unmerged-first, opt-in `#N` GitHub PR
- **Context** — `ssh` / `root` / `dkr` / `ctr` / `k8s:<ctx>/<ns>`, opt-in `aws` / `gcp` / `az`. Pure-fish, no CLI forks
- **Lang + env** — 10 langs via pin files first. `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<devshell>)`
- **Terraform / Pulumi** — opt-in `tf:<workspace>` / `pulumi:<stack>`
- **Terminal-native** — OSC 7 + OSC 133, opt-in OSC 9 + `notify-send` long-command alert
- **9 palettes** — Catppuccin x4 + gruvbox / tokyonight / rosepine / nord / dracula. Live switch via `damin_set_palette`
- **Transient prompt**, **vi-mode badge**, **ASCII fallback**, **TRAMP / dumb auto-minimal**
- **Customizable** — 35+ `theme_damin_*` toggles, `damin_segment_<name>` hooks

## Commands

| Command                | Purpose                                                                |
|------------------------|------------------------------------------------------------------------|
| `damin_config`         | Interactive setup wizard                                               |
| `damin_help`           | List every toggle, current value, default                              |
| `damin_doctor`         | Environment + install diagnostic                                       |
| `damin_profile`        | Per-segment ms/render timer (means)                                    |
| `damin_bench`          | Per-segment P50/P95/P99 distribution                                   |
| `damin_set_palette`    | Switch palette                                                         |
| `damin_install_themes` | Write `.theme` files into `~/.config/fish/themes/`                     |
| `damin_reset_cache`    | Wipe on-disk cache                                                     |

## Configuration

Every option is a `theme_damin_*` universal variable. `damin_help` lists them all; full reference + palette + cache details in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

```fish
set -U theme_damin_show_jobs 0
```

## Troubleshooting

Nuke and reinstall.

**Fisher**

```fish
damin_reset_cache
fisher remove miniex/fish-theme-damin
fisher install miniex/fish-theme-damin
exec fish
```

**Oh My Fish**

```fish
damin_reset_cache
omf theme default; and rm -rf ~/.local/share/omf/themes/fish-theme-damin
omf install https://github.com/miniex/fish-theme-damin; and omf theme fish-theme-damin
exec fish
```

Run `damin_doctor` if anything looks off. `Conflicting prompt setting` after reinstall = stale symlink (`hooks/install.fish` handles this; on older installs, `rm ~/.config/fish/functions/fish_prompt.fish; omf theme fish-theme-damin`).

## Companion repos

- [btop-theme-damin](https://github.com/miniex/btop-theme-damin) — btop theme
- [dotfiles.tmux](https://github.com/miniex/dotfiles.tmux) — tmux config
- [dotfiles.kitty](https://github.com/miniex/dotfiles.kitty) — kitty terminal config
- [dotfiles.nvim](https://github.com/miniex/dotfiles.nvim) — Neovim config

## Contributing

PRs welcome. Run `./tools/format.sh`, `./tools/lint.sh`, `./tools/test.sh`. Hot-path changes need before / after `./tools/bench.sh` numbers. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Current version: **1.1.0**.

## License

[MIT](LICENSE) © 2026 Han Damin. Bundled palette hex values are MIT-licensed third-party color schemes (Catppuccin, Gruvbox, Tokyo Night, Rosé Pine, Nord, Dracula) — see [`LICENSES/`](LICENSES/).

[fisher]: https://github.com/jorgebucaran/fisher
[omf]:    https://github.com/oh-my-fish/oh-my-fish
