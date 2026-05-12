# fish-theme-damin

> A small, opinionated fish prompt — works with [Fisher][fisher] and [Oh My Fish][omf]. Florette (`✿`) on the left, heart bullet (`❥`) on the right, two-color palette (`#98ABCC` / `#E890B0`). Pure Dingbats — no Nerd Font required.

## Preview

![damin prompt walkthrough](assets/preview.gif)

```
master ✗3 ✓1 #42 [N] ✿                        ❥ ~/code · node:22 · 120 ms
master (rebase) wt:feat-x X2 ✿                ❥ ~/code · 50 ms
ssh aws:prod@us-east-1 master ✿               ❥ ~/foo · py:3.12 · 250 ms
master ✿ SIGINT                                          ❥ ~/bug · 3.2 s
```

After Enter, past prompts collapse to just `✿` so scrollback stays tidy.

## Install

**Fisher**

```fish
fisher install miniex/fish-theme-damin
```

**Oh My Fish**

```fish
omf install https://github.com/miniex/fish-theme-damin
omf theme fish-theme-damin
```

For local hacking:

```fish
git clone https://github.com/miniex/fish-theme-damin.git
# fisher
fisher install (pwd)/fish-theme-damin
# OR omf
ln -sfn (pwd)/fish-theme-damin ~/.local/share/omf/themes/fish-theme-damin
omf theme fish-theme-damin
```

Requires **fish ≥ 3.7** (for the `path mtime` builtin). Works with **Fisher** (auto-loads via `conf.d/` + `functions/`) and **Oh My Fish** (root shims source the same code).

## Highlights

- **Sub-millisecond hot path** — caches + event-driven invalidation. No background forks on every prompt
- **Smart git/jj integration** — counts (`X2 ?2 ✗3 ✓1`), op state (`(rebase)`), `wt:<name>` inside `git worktree`, jj support, postexec invalidation that skips read-only commands. Unmerged files surface first in bold red. Optional `#N` for the current branch's open GitHub PR (via `gh`, cached)
- **Context indicators** — `ssh`, `root`, `dkr`, `ctr` plus `k8s:<context>` (parsed from `~/.kube/config` / `$KUBECONFIG`; pure-fish, no `kubectl` fork) with optional `/<namespace>`. `&N` for background jobs
- **Cloud context** — opt-in `aws:<profile>@<region>` (env + `~/.aws/config`), `gcp:<project>` (`~/.config/gcloud/`), `az:<subscription>` (env + `~/.azure/azureProfile.json`). Pure-fish, mtime-cached, no CLI forks
- **Language + env** — `node:22`, `rust:1.78`, `py:3.12`, `rb:3.3`, `java:21`, `ex:1.16`, `php:8.3`, `cr:1.10`, `zig:0.12`. Pin-file first (`.tool-versions` / `.mise.toml` / `.python-version` / `.nvmrc` / `.node-version` / `.ruby-version` / `.java-version`) so the prompt skips the binary fork on most projects. Active `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<devshell>)` shown next to it
- **Terraform + Pulumi** — opt-in `tf:<workspace>` (reads `.terraform/environment`) and `pulumi:<stack>` (`$PULUMI_STACK` or `~/.pulumi/workspaces/<proj>-*-workspace.json`). Single walk-up resolver, pwd-cached
- **Terminal-native shell integration** — OSC 7 (advertises cwd so new tabs/splits open in the same directory) + OSC 133 (semantic prompt markers for "jump to prompt" / "select command output" in Ghostty, iTerm2, Kitty, WezTerm, VS Code, Windows Terminal). Unsupporting terminals silently ignore; opt out via `theme_damin_osc_integration 0`
- **Long-command notification** — opt-in desktop alert (OSC 9 + `notify-send`) when a command runs longer than `theme_damin_notify_threshold` (default 30 s). Walk away, the prompt taps you back
- **Exit-code labels** — `theme_damin_show_exit_code` is an enum: `number` (default), `name` (`SIGINT` / `not-found` / `SIGKILL` via fish's `fish_status_to_signal`), `both`, or `off`
- **Vi mode badge** — `[N]` / `[I]` / `[V]` / `[R]` shown next to the florette when `fish_vi_key_bindings` is active; auto-repaints on mode change. Off entirely under emacs bindings
- **9 palettes** — `theme_damin_palette` picks from `mocha` (default), `frappe`, `macchiato`, `latte`, `gruvbox`, `tokyonight`, `rosepine`, `nord`, `dracula`. Catppuccin variants keep the original cherry-blossom brand accents; new palettes shift to palette-native primary/secondary. Override with `theme_damin_accent_primary` / `theme_damin_accent_secondary`. Switch live with `damin_set_palette dracula`
- **`fish_config` integration** — `damin_install_themes` writes 9 `Damin <Palette>.theme` files into `~/.config/fish/themes/` so they show up in `fish_config theme show` (generated inline — no extra files in the repo to keep in sync)
- **Async cache warmup** — when fish opens directly into a repo, a background fork pre-fills the git cache so the next prompt is already hot
- **True async repaint** (opt-in) — `theme_damin_async_repaint 1` renders immediately on stale or missing git cache, runs the refresh in a `fish -c` subshell, then triggers `commandline -f repaint` once the fresh data is on disk. Useful for very large repos where porcelain v2 takes meaningful time
- **Auto-minimal on TRAMP / dumb terminals** — `$TERM=dumb` or `$INSIDE_EMACS` set ⇒ ascii glyphs, no transient, no OSC, no palette mutation, all without nuking user-explicit settings
- **Transient prompt** — past prompts collapse to `✿` after Enter
- **ASCII fallback** — if your terminal font is missing dingbats (`⇡ ⇣ ❥ ✧`), `set -U theme_damin_ascii 1` swaps every glyph for safe ASCII; or override one at a time via `theme_damin_glyph_*`
- **Interactive setup** — `damin_config` wizard walks you through the high-value toggles. `damin_help` is the full reference; the wizard is the onramp
- **Custom segments** — `set -U theme_damin_extra_left mything` and define `function damin_segment_mything; …; end`. Same for `_right`. Drop-in extension without forking
- **35+ toggles** via `set -U theme_damin_*` — run `damin_help` to discover

## Commands

| Command                  | Purpose                                                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `damin_config`           | Interactive setup wizard — toggles + palette picker                                                                      |
| `damin_help`             | List every toggle, current value, and default                                                                            |
| `damin_doctor`           | Environment, install, font-width, and prompt-source diagnostic                                                           |
| `damin_profile`          | Time each segment renderer (`damin_profile [N=20]`) and print ms/render                                                  |
| `damin_set_palette`      | Switch palette (`mocha` / `frappe` / `macchiato` / `latte` / `gruvbox` / `tokyonight` / `rosepine` / `nord` / `dracula`) |
| `damin_install_themes`   | Install bundled `.theme` files so `fish_config theme show` lists them                                                    |
| `damin_reset_cache`      | Wipe the on-disk cache when something looks wrong                                                                        |

## Configuration

Everything is gated by a `theme_damin_*` universal variable. Quick example — turn off jobs counter:

```fish
set -U theme_damin_show_jobs 0
```

Full toggle reference, palette, performance numbers, and cache architecture in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Troubleshooting

Something looks stale or wrong after an update? Nuke and reinstall:

```fish
# 1. clear the on-disk cache
damin_reset_cache
# OR — if the function is missing or broken, delete the dir yourself
rm -rf ~/.cache/damin

# 2. uninstall
fisher remove miniex/fish-theme-damin                                       # Fisher
omf theme default; and rm -rf ~/.local/share/omf/themes/fish-theme-damin    # OMF

# 3. reinstall
fisher install miniex/fish-theme-damin                                              # Fisher
omf install https://github.com/miniex/fish-theme-damin; and omf theme fish-theme-damin  # OMF

# 4. apply in the current shell
exec fish
```

Still off? Run `damin_doctor` — it reports cache state, font width, where `fish_prompt` is loaded from, and whether the `~/.config/fish/functions/fish_prompt.fish` symlink matches the OMF active theme. Prompt definitions live in `conf.d/damin.fish`, not `functions/`, so Fisher doesn't deposit a stub into the autoload dir.

If you hit `Conflicting prompt setting` after `omf remove` → `omf install`, OMF left a stale symlink pointing into the now-removed theme dir. The bundled `hooks/install.fish` cleans this up automatically on `omf install`; if you're on an older install, drop it manually: `rm ~/.config/fish/functions/fish_prompt.fish; omf theme fish-theme-damin`.

## Contributing

PRs welcome. Install `fish` (`fish_indent`), `shfmt`, `shellcheck`, then run `./tools/format.sh`, `./tools/lint.sh`, and `./tools/test.sh`. See [CONTRIBUTING.md](CONTRIBUTING.md) for the commit-prefix convention. Hot-path changes should include before/after `./tools/bench.sh` numbers in the PR description.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Current version: **1.0.0**.

## License

[MIT](LICENSE) © 2026 Han Damin.

Third-party licenses live in [`LICENSES/`](LICENSES/). The bundled `fish_color_*` palettes and the `Damin *.theme` files written by `damin_install_themes` use upstream hex codes from third-party color schemes — all MIT-licensed:

- [Catppuccin](https://github.com/catppuccin/catppuccin) — Mocha, Frappé, Macchiato, Latte (© 2021 Catppuccin). Values verified against [`catppuccin/palette`](https://github.com/catppuccin/palette) `palette.json`
- [Gruvbox](https://github.com/morhetz/gruvbox) — © Pavel Pertsev (MIT/X11, declared in upstream README)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) — © 2018-present Enkia
- [Rosé Pine](https://github.com/rose-pine/rose-pine-theme) — © 2023 Rosé Pine
- [Nord](https://github.com/nordtheme/nord) — © 2016-present Sven Greb
- [Dracula](https://github.com/dracula/dracula-theme) — © 2023 Dracula Theme

[fisher]: https://github.com/jorgebucaran/fisher
[omf]:    https://github.com/oh-my-fish/oh-my-fish
