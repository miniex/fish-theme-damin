# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `theme_damin_ascii` toggle — `set -U theme_damin_ascii 1` swaps every prompt glyph to a safe ASCII fallback for terminals whose font lacks the dingbat glyphs (`⇡ ⇣ ❥ ✧ ✿ ✗ ✓ ·`). Defaults: `* > ~ ! + ? $ ^ v |`
- 10 `theme_damin_glyph_*` variables for individual symbol overrides (`prompt`, `cwd`, `clean`, `modified`, `added`, `untracked`, `stashed`, `ahead`, `behind`, `sep`). User overrides win over both fancy and ASCII defaults
- `damin_doctor` now reports the active glyph mode and the cached cache-entry count, and the font-width sanity hint suggests `theme_damin_ascii=1` when glyphs render as `?`

### Fixed

- `_damin_git_compute` parsed `git status --porcelain=v2 --branch` with `case '?'`, but fish's `case` uses glob semantics — the `?` wildcard matched **every** single character, so `# branch.head main` and `1 .M …` lines all fell into the untracked counter. Branch name stayed empty (rendered as fallback `?`) and modified/staged/ahead/behind counts were always `0`. Now uses `case '\?'` to match the literal character. Existing caches must be cleared (`damin_reset_cache`) for the fix to take effect

### Changed

- Battery percent (`theme_damin_show_battery`) now resolves per-platform via `switch (uname)` — macOS `pmset`, Linux sysfs, FreeBSD / OpenBSD / NetBSD / DragonFly `apm -l` with `sysctl hw.acpi.battery.life` fallback. Previously non-Darwin BSDs fell through to the Linux sysfs path

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

[Unreleased]: https://github.com/miniex/fish-theme-damin/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/miniex/fish-theme-damin/releases/tag/v1.0.0
