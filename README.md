# fish-theme-damin

> A small, opinionated fish prompt — works with [Fisher][fisher] and [Oh My Fish][omf]. Florette (`✿`) on the left, heart bullet (`❥`) on the right, two-color palette (`#98ABCC` / `#E890B0`). Pure Dingbats — no Nerd Font required.

## Preview

![damin prompt walkthrough](assets/preview.gif)

```
master ✗3 ✓1 ✿                               ❥ ~/code · node:22 · 120 ms
ssh master (rebase) ✿                         ❥ ~/foo · py:3.12 · 250 ms
master ✿ 127                                             ❥ ~/bug · 3.2 s
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
- **Smart git/jj integration** — counts (`?2 ✗3 ✓1`), op state (`(rebase)`), worktree-aware, jj support, postexec invalidation that skips read-only commands
- **Context indicators** — `ssh`, `root`, `dkr`, `ctr` plus `k8s:<context>` (parsed from `~/.kube/config` / `$KUBECONFIG`; pure-fish, no `kubectl` fork) with optional `/<namespace>`. `&N` for background jobs
- **Language + env** — `node:22`, `rust:1.78`, `py:3.12`, etc. with active `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<devshell>)` display — direnv shows the project dir, `nix:` shows the flake's `name` attr
- **Transient prompt** — past prompts collapse to `✿` after Enter
- **Catppuccin Mocha** `fish_color_*` palette applied on theme activation (opt-out via `theme_damin_apply_colors 0`)
- **ASCII fallback** — if your terminal font is missing dingbats (`⇡ ⇣ ❥ ✧`), `set -U theme_damin_ascii 1` swaps every glyph for safe ASCII; or override one at a time via `theme_damin_glyph_*`
- **20+ toggles** via `set -U theme_damin_*` — run `damin_help` to discover

## Commands

| Command             | Purpose                                           |
|---------------------|---------------------------------------------------|
| `damin_help`        | List every toggle, current value, and default     |
| `damin_doctor`      | Environment, install, font-width, and prompt-source diagnostic |
| `damin_reset_cache` | Wipe the on-disk cache when something looks wrong |

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
fisher remove miniex/fish-theme-damin   # Fisher
# OR — OMF: switch off the theme, then delete the dir yourself
#         (omf remove can leave stale theme files behind)
omf theme default
rm -rf ~/.local/share/omf/themes/fish-theme-damin

# 3. reinstall
fisher install miniex/fish-theme-damin  # Fisher
# OR
omf install https://github.com/miniex/fish-theme-damin; and omf theme fish-theme-damin

# 4. apply in the current shell
exec fish
```

Still off? Run `damin_doctor` — it reports cache state, font width, where `fish_prompt` is loaded from, and any stray prompt files in `~/.config/fish/functions/`. The prompt definitions live in `conf.d/damin.fish`, not in `functions/`, so Fisher never copies a `fish_prompt.fish` into your autoload dir and switching between Fisher / OMF doesn't leave a `Conflicting prompt setting` behind.

## Contributing

PRs welcome. Install `fish` (`fish_indent`), `shfmt`, `shellcheck`, then run `./tools/format.sh`, `./tools/lint.sh`, and `./tools/test.sh`. See [CONTRIBUTING.md](CONTRIBUTING.md) for the commit-prefix convention. Hot-path changes should include before/after `./tools/bench.sh` numbers in the PR description.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Current version: **1.0.0**.

## License

[MIT](LICENSE) © 2026 Han Damin.

Third-party licenses live in [`LICENSES/`](LICENSES/). The bundled `fish_color_*` palette is [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) (MIT, © 2021 Catppuccin).

[fisher]: https://github.com/jorgebucaran/fisher
[omf]:    https://github.com/oh-my-fish/oh-my-fish
