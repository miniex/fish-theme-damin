# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 20260512214953 KST

### Added

#### Segments

- Cloud context — opt-in `aws:<profile>@<region>`, `gcp:<project>`, `az:<subscription>`. Pure-fish parsers, no CLI forks
- K8s context — `k8s:<context>` (optional `/<namespace>`) from kubeconfig. Replaces 1.0.0's bare `k8s` flag
- Terraform + Pulumi — opt-in `tf:<workspace>`, `pulumi:<stack>`
- GitHub PR — opt-in `#<num>` via `gh` for the current branch's open PR (cached, draft = dim)
- Worktree indicator `wt:<name>`
- Conflict count `XN` — porcelain v2 unmerged lines, bold red, always visible
- Vi mode badge — `[N]` / `[I]` / `[V]` / `[R]`, auto-repaints on mode change
- Custom segment hooks — `theme_damin_extra_left` / `_right` + `damin_segment_<name>` for drop-in extension

#### Language + env

- 6 more languages — ruby / java / elixir / php / crystal / zig
- Pin-file resolution — `.tool-versions` / `.mise.toml` / `.python-version` / `.nvmrc` / `.node-version` / `.ruby-version` / `.java-version` before falling back to a binary fork
- Named `(env)` — `(direnv:<dir>)`, `(nix:<devshell>)` from the derivation `name` attr

#### Theming

- 9 palettes — Catppuccin (mocha / frappe / macchiato / latte) + gruvbox / tokyonight / rosepine / nord / dracula. `damin_set_palette <flavor>` swaps live
- `damin_install_themes` — writes 9 `.theme` files for `fish_config theme show`
- `theme_damin_accent_primary` / `_secondary` overrides
- ASCII fallback — `theme_damin_ascii=1` + 10 `theme_damin_glyph_*` per-symbol overrides

#### Shell integration

- OSC 7 + OSC 133 — cwd advertise + semantic prompt markers (Ghostty / iTerm2 / Kitty / WezTerm / VS Code / Windows Terminal / Warp)
- Long-command desktop notification — opt-in OSC 9 + `notify-send` past `theme_damin_notify_threshold`
- TRAMP / dumb terminal auto-minimal — `$TERM=dumb` / `$INSIDE_EMACS` triggers ASCII glyphs, no transient, no OSC, no palette mutation (user overrides still win)

#### Customization + tools

- `theme_damin_show_exit_code` enum — `number` (default) / `name` (`SIGINT` / `not-found` / `SIGKILL`) / `both` / `off`
- `damin_config` — interactive setup wizard (11 toggles + palette picker)
- `damin_profile` — per-segment ms/render timer
- `damin_doctor` — checks `fish_prompt` source, OMF symlink ↔ active theme match, transient bindings on `\r`, scope leaks, glyph mode, cache state, autoload paths
- `hooks/install.fish` — OMF install hook that auto-clears stale `fish_prompt.fish` symlinks (avoids `Conflicting prompt setting` on reinstall)

#### Performance

- Async cache warmup — backgrounded fork fills git + k8s cache at theme load
- True async repaint (opt-in `theme_damin_async_repaint 1`) — for very large repos where porcelain v2 takes meaningful time
- K8s disk cache — skips kubeconfig re-parse on cold start
- `tools/test.sh` — POSIX harness covering git / k8s / env / cloud / OSC paths

### Fixed

- Vi mode badge double-rendered — fish's default `fish_mode_prompt` ran before damin's inline badge. Now blanked
- `omf remove` → `omf install` → `omf theme <name>` tripped `Conflicting prompt setting` because the orphan `fish_prompt.fish` symlink revived. Fixed via `hooks/install.fish`
- `damin_doctor` false positives — flagged legit OMF symlink as stray and hard-coded the theme name. Now matches against the active theme path
- `_damin_git_compute` parsed porcelain v2 with `case '?'` — fish's glob `?` matched every char, so untracked counted everything and branch / modified / staged / ahead / behind all read as 0. Now uses `case '\?'`
- `⇡` ahead never showed without upstream tracking. Falls back to `git rev-list --count HEAD --not --remotes`
- `theme_damin_show_git_op` toggle was never read — op state (`rebase` / `merge` / …) always rendered. Now gated
- Async git cache went stale on out-of-shell commits (lazygit / IDE plugins / `bash -c`). Now invalidates via `path mtime` on `.git/{index,HEAD,logs/HEAD}`
- `theme_damin_apply_colors=1` clobbered user-customized `fish_color_*` universals. Now only fills in unset
- Transient prompt — vi-mode dead-bind, universal-scope flag leak, overridden `fish_right_prompt` stranded state, incomplete-buffer corruption. All fixed
- Fisher install used to copy `fish_prompt.fish` into autoload dir, which OMF flagged as `Conflicting prompt setting`. Definitions moved to `conf.d/`; `fisher update` cleans up old installs

### Changed

- **Minimum fish version 3.6 → 3.7** — required for the `path mtime` builtin (cache-freshness without `stat` forks)
- Battery percent — per-platform via `uname` (macOS `pmset`, Linux sysfs, BSD `apm -l` / `sysctl`)

## [1.0.0] - 20260511223917 KST

Initial release.

### Added

- **Dual-manager support** — works with **Fisher** (`fisher install miniex/fish-theme-damin`) via `conf.d/damin.fish` + `functions/*.fish`, and with **Oh My Fish** (`omf install …`) via root-level shims that source the same code
- Florette `✿` prompt symbol (pink on success, red on failure) + heart bullet `❥` right-prompt decoration. Pure Dingbats — no Nerd Font required
- Two-color palette anchored to `#98ABCC` / `#E890B0`
- Catppuccin Mocha `fish_color_*` palette applied on theme activation (`theme_damin_apply_colors`)
- Cached git status with event-driven invalidation via `fish_postexec`. Read-only commands (`git status` / `log` / `diff` / …) skip invalidation
- Worktree-aware git compute (`--git-common-dir` for stash log)
- Git operation state — `(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)` from `.git/` files
- Jujutsu (`jj`) support — bookmark or change-id short when `.jj/` is encountered before `.git/`
- Detailed git status counts next to each indicator (`?3 ✗2 ✓1 ⇣2 ⇡1`)
- Clean-repo sparkle `✧` when nothing is dirty
- Context indicators — `ssh` / `root` / `dkr` / `ctr` / `k8s`
- Background-job count `&N`
- Language + version detection (rust / node / go / python / deno), cached per-PWD with postexec invalidation on version-manager commands (`nvm` / `mise` / `pyenv` / …)
- Active environment indicator — `(.venv)` / `(conda)` / `(direnv)`
- Battery percent (opt-in, 60 s TTL)
- Exit code shown after the florette on non-zero status
- Long-command duration emphasis when over threshold
- Smart cwd truncation via `prompt_pwd --dir-length` / `--full-length-dirs`
- Transient prompt — past prompts collapse to a single `✿` after Enter
- 19 user toggles under `theme_damin_*`
- User commands — `damin_help`, `damin_doctor`, `damin_reset_cache`
- Tooling — `tools/format.sh`, `tools/lint.sh`, `tools/bench.sh`
- `assets/preview.gif` walkthrough
- Documentation — `README.md`, `docs/ARCHITECTURE.md`, `CONTRIBUTING.md`
- Third-party attribution — `LICENSES/catppuccin.txt`

[Unreleased]: https://github.com/miniex/fish-theme-damin/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/miniex/fish-theme-damin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/miniex/fish-theme-damin/releases/tag/v1.0.0
