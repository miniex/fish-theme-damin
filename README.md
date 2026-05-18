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
omf install damin
omf theme damin
```

**Local hacking — Fisher**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
fisher install (pwd)/fish-theme-damin
```

**Local hacking — Oh My Fish**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
ln -sfn (pwd)/fish-theme-damin ~/.local/share/omf/themes/damin
omf theme damin
```

## Update

**Fisher**

```fish
fisher update miniex/fish-theme-damin
```

**Oh My Fish**

```fish
omf update damin   # just this theme
omf update         # framework + all packages
```

## Highlights

- **Fast** — ~0.5 ms/prompt. In-memory PWD memos on lang/git/cwd skip disk i/o after the first prompt. Async refresh forks a ~3 KB core. Cloud/devops/battery/jj/hg/fossil autoload only when enabled. `-uno` opt-out for monorepos. `theme_damin_vcs_ignore_paths` glob-skips the walk-up on NFS/huge mounts
- **git / jj / hg / fossil** — counts (`X2 ?2 ✗3 ✓1 ⇡N`), op state, `wt:<name>`, unmerged-first, opt-in `#N` GitHub PR. `hide_default_branch`, `branch_max_len` for long branch names
- **Context** — `ssh` / `root` / `sudo:<user>` / `dkr` / `ctr` / `dm:<machine>` / `screen:<session>` / `k8s:<ctx>/<ns>`, opt-in `aws` / `aws-vault` / `gcp` / `az`. SSH-aware `user@host` + `default_user` to hide your own. Pure-fish, no CLI forks. `theme_damin_cloud_max_len` (+ per-segment `_k8s_max_len` / `_aws_max_len` / `_gcp_max_len` / `_azure_max_len`) clips long ARN-style labels with `…`
- **Lang + env** — 10 langs via pin files first. `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<devshell>)`. Opt-in global-version-manager fallback (rbenv/pyenv/NVM/asdf)
- **Terraform / Pulumi** — opt-in `tf:<workspace>` / `pulumi:<stack>`
- **Path** — abbreviated cwd, optional project-relative (`<project>/<rel>`) mode
- **Terminal-native** — OSC 7 + OSC 133, opt-in OSC 9 + `notify-send` long-command alert. Configurable terminal title + right-prompt clock
- **17 palettes** — Catppuccin x4 + gruvbox(+light) / tokyonight / rosepine / nord / dracula / solarized(+light) / base16(+light) / zenburn / terminal-dark/-light. Live switch via `damin_set_palette`. `damin_colors` hook for per-segment overrides
- **Transient prompt**, **vi-mode badge**, **multi-line option** (`newline_prompt`), **ASCII fallback**, **TRAMP / dumb auto-minimal**
- **Customizable** — 60+ `theme_damin_*` toggles, `damin_segment_<name>` + `damin_colors` hooks

## Commands

Every `damin_*` command answers `--help` / `-h` with a usage block. Tab completions for subcommands, palette names, and flags are auto-installed.

| Command                | Purpose                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `damin_config`         | Interactive setup wizard                                        |
| `damin_config get` …   | Print matching `theme_damin_*` (`damin_config get git`)         |
| `damin_config set` …   | `set -U` a `theme_damin_*` var (`damin_config set show_jobs 0`) |
| `damin_config reset` … | Unset matching universals after `y/N` confirm                   |
| `damin_config export`  | Dump universals as a runnable fish script (dotfile-friendly)    |
| `damin_help`           | List every toggle, current value, default                       |
| `damin_doctor`         | Environment + install diagnostic                                |
| `damin_profile`        | Per-segment ms/render timer (means)                             |
| `damin_bench`          | Per-segment P50/P95/P99 distribution                            |
| `damin_set_palette`    | Switch palette                                                  |
| `damin_install_themes` | Write `.theme` files into `~/.config/fish/themes/`              |
| `damin_reset_cache`    | Wipe on-disk cache                                              |

## Configuration

Every option is a `theme_damin_*` universal variable. `damin_help` lists them all; full reference + palette + cache details in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

```fish
# either way works:
set -U theme_damin_show_jobs 0
damin_config set theme_damin_show_jobs 0
```

Dotfile users can capture every override with `damin_config export > ~/dotfiles/damin.fish` and replay via `source`.

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
omf theme default; and rm -rf ~/.local/share/omf/themes/damin
omf install damin; and omf theme damin
exec fish
```

Run `damin_doctor` if anything looks off. `Conflicting prompt setting` after reinstall = stale symlink (`hooks/install.fish` handles this; on older installs, `rm ~/.config/fish/functions/fish_prompt.fish; omf theme damin`).

## Companion repos

- [btop-theme-damin](https://github.com/miniex/btop-theme-damin) — btop theme
- [dotfiles.tmux](https://github.com/miniex/dotfiles.tmux) — tmux config
- [dotfiles.kitty](https://github.com/miniex/dotfiles.kitty) — kitty terminal config
- [dotfiles.nvim](https://github.com/miniex/dotfiles.nvim) — Neovim config

## Contributing

PRs welcome. Run `./tools/format.sh`, `./tools/lint.sh`, `./tools/test.sh`. Hot-path changes need before / after `./tools/bench.sh` numbers. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Current version: **1.2.0**.

## License

[MIT](LICENSE) © 2026 Han Damin. Bundled palette hex values are MIT-licensed third-party color schemes (Catppuccin, Gruvbox, Tokyo Night, Rosé Pine, Nord, Dracula) — see [`LICENSES/`](LICENSES/).

[fisher]: https://github.com/jorgebucaran/fisher
[omf]: https://github.com/oh-my-fish/oh-my-fish
