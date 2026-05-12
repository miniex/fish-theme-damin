# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **OSC 7 + OSC 133 shell integration** — the prompt now emits `\e]7;file://<host><path>\a` on PWD change (terminal opens new tabs/splits in the same dir) and `\e]133;A/B/C/D;<exit>\a` markers around the prompt + command lifecycle (semantic regions for "jump to prompt" / "select command output" in Ghostty, iTerm2, Kitty, WezTerm, VS Code, Windows Terminal, Warp). Path is percent-encoded per segment via `string escape --style=url` so spaces and non-ASCII survive. Unsupported terminals are required by spec to drop unrecognized OSC sequences silently. Toggle: `theme_damin_osc_integration` (default 1)
- **AWS / GCP / Azure context** — opt-in `aws:<profile>@<region>`, `gcp:<project>`, `az:<subscription>` stack alongside the existing `ssh` / `root` / `dkr` / `ctr` / `k8s` context segment. All three are pure-fish: AWS reads `AWS_PROFILE` / `AWS_REGION` then walks `~/.aws/config` (`[default]` or `[profile <name>]`); GCP short-circuits on `CLOUDSDK_CORE_PROJECT`, otherwise reads `~/.config/gcloud/active_config` + the matching `configurations/config_<name>` INI for `[core] project`; Azure short-circuits on `AZURE_SUBSCRIPTION_NAME` / `AZURE_DEFAULTS_SUBSCRIPTION`, otherwise splits `~/.azure/azureProfile.json` on `},` and extracts the `"name"` of the chunk containing `"isDefault": true`. All three mtime-cached so unchanged config files cost one `path mtime` call; `_damin_postexec` drops the caches on `aws` / `gcloud` / `az` commands to dodge same-second mutations. Toggles: `theme_damin_show_aws` / `theme_damin_show_aws_region` / `theme_damin_show_gcp` / `theme_damin_show_azure` (all default 0 except region append, default 1)
- **GitHub PR number** — opt-in `#<num>` segment next to the git meta block when the current branch has an open PR. Skips silently when `gh` is missing, when the origin remote isn't on `github.com`, or when no PR is associated. Result is cached by `(branch, age)` and refreshed when stale (default 5 min) or when `_damin_postexec` sees a state-changing `gh pr` subcommand (`create` / `close` / `reopen` / `merge` / `edit`). Draft PRs render dim. Toggles: `theme_damin_show_gh_pr` (default 0), `theme_damin_gh_pr_ttl` (default 300)
- `k8s:<context>` and optional `/<namespace>` indicator — replaces the bare `k8s` flag (which only fired inside a pod via `$KUBERNETES_SERVICE_HOST`) with the active context name parsed from `$KUBECONFIG`'s first path or `~/.kube/config`. Pure-fish YAML parser collects every context block first then resolves the match, so the file's section order doesn't matter; result is cached in process-local globals and invalidated by `path mtime` on the config file (no `kubectl` fork on any prompt). Falls back to bare `k8s` inside a pod when no config is readable. Toggles: `theme_damin_show_k8s_context` (default 1), `theme_damin_show_k8s_namespace` (default 0 — namespace adds length so it's opt-in)
- nix devshell and direnv project naming inside the `(env)` segment — `(direnv)` now shows `(direnv:<project>)` from the basename of `$DIRENV_DIR` (with direnv's leading `-` marker stripped), and `IN_NIX_SHELL` now surfaces as `(nix:<name>)` when the derivation's `name` attr is descriptive (a flake setting `name = "rust-shell"`), collapsing to bare `(nix)` for the generic `nix-shell` / `nix-shell-env` defaults. Toggle: `theme_damin_show_nix_name` (default 1)
- `theme_damin_ascii` toggle — `set -U theme_damin_ascii 1` swaps every prompt glyph to a safe ASCII fallback for terminals whose font lacks the dingbat glyphs (`⇡ ⇣ ❥ ✧ ✿ ✗ ✓ ·`). Defaults: `* > ~ ! + ? $ ^ v |`
- 10 `theme_damin_glyph_*` variables for individual symbol overrides (`prompt`, `cwd`, `clean`, `modified`, `added`, `untracked`, `stashed`, `ahead`, `behind`, `sep`). User overrides win over both fancy and ASCII defaults
- `damin_doctor` now reports the active glyph mode and the cached cache-entry count, and the font-width sanity hint suggests `theme_damin_ascii=1` when glyphs render as `?`
- `damin_doctor` new diagnostics — verifies `fish_prompt` is loaded and prints the source path, flags stray symlinks at `~/.config/fish/functions/fish_prompt.fish` / `fish_right_prompt.fish` (neither OMF nor Fisher creates these — typically a manual install or stale leftover that triggers OMF's `Conflicting prompt setting`), and checks `damin_help` / `damin_reset_cache` are on the autoload path
- `damin_doctor` transient diagnostics — confirms `\r` is still bound to `_damin_transient_enter` in `default` / `insert` (catches fzf / atuin rebinding Enter after damin loaded) and flags `_damin_in_transient` leaked to universal scope (which pins every prompt to the stub forever)
- `tools/test.sh` — POSIX-shell harness that runs `_damin_git_compute` against fixture git repos (clean / dirty mixes / detached HEAD / stash / upstream ahead-behind / no-upstream rev-list fallback / rebase / merge / `theme_damin_show_git_op=0` gate), `_damin_k8s_compute` against fixture kubeconfigs (single context, multiple contexts, no namespace, current-context before contexts, quoted values), `_damin_env_render` for direnv/nix combinations, `_damin_aws_region_for` against fixture `~/.aws/config` files (default + named profile + unknown), `_damin_azure_compute` against fixture `azureProfile.json` (first-default / second-default / no-default / missing), `_damin_gcp_render` against fixture `~/.config/gcloud/` trees + the `CLOUDSDK_CORE_PROJECT` short-circuit, and the OSC 7 / OSC 133 emit/skip + path-encoding paths. Covers every prior parser regression so the next porcelain-v2 / kubeconfig / env / cloud / OSC edge case fails loudly
- `README.md` Troubleshooting section — nuke-and-reinstall recipe covering cache clear (`damin_reset_cache` or `rm -rf ~/.cache/damin`), Fisher / OMF uninstall (OMF: `omf theme default` + `rm -rf ~/.local/share/omf/themes/fish-theme-damin` to avoid leftover files), reinstall, and `exec fish` to apply. Includes a `Conflicting prompt setting` follow-up for users switching from Fisher to OMF without cleaning up Fisher's copy of `fish_prompt.fish`

### Fixed

- `damin_doctor` checked `~/.config/omf/theme` against the literal string `damin`, but `omf install https://github.com/miniex/fish-theme-damin` clones into `~/.local/share/omf/themes/fish-theme-damin/` — so a correctly-installed setup always failed the check, and the suggested recovery (`omf theme damin`) failed with "Theme not installed!" because no such theme directory exists. Now matches `fish-theme-damin` and the hint points at the correct command
- `_damin_git_compute` parsed `git status --porcelain=v2 --branch` with `case '?'`, but fish's `case` uses glob semantics — the `?` wildcard matched **every** single character, so `# branch.head main` and `1 .M …` lines all fell into the untracked counter. Branch name stayed empty (rendered as fallback `?`) and modified/staged/ahead/behind counts were always `0`. Now uses `case '\?'` to match the literal character. Existing caches must be cleared (`damin_reset_cache`) for the fix to take effect
- `⇡` ahead indicator never showed when the branch had no upstream tracking. `git status --porcelain=v2 --branch` omits `# branch.ab` without an upstream, so a fresh feature branch full of unpushed commits looked clean. Now falls back to `git rev-list --count HEAD --not --remotes` when no upstream is set (and at least one remote exists), so unpushed commits surface as `⇡N` regardless of whether `--set-upstream` has been run
- `theme_damin_show_git_op` toggle was listed in `damin_help` and `docs/ARCHITECTURE.md` but never read — `(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)` always rendered. Now gates op-state detection in `_damin_git_compute`
- Async git cache went stale on out-of-shell commits — `lazygit`, IDE git plugins, scripts invoked via `bash -c`, etc. bypass `fish_postexec` so the prompt kept serving pre-commit state until manual `damin_reset_cache`. Now compares cache mtime against `.git/{index,HEAD,logs/HEAD}` via `path mtime` (single builtin call, no fork), recomputes when any git state file is newer
- `theme_damin_apply_colors=1` used `set -U fish_color_*` unconditionally on every shell startup, clobbering user-customized colors and persisting them across `theme_damin_apply_colors=0` later (universal scope is sticky). Now uses `set -q X; or set -U X val` so existing customizations win and damin only fills in what's unset
- Transient prompt was dead under vi mode — `bind \r _damin_transient_enter` only registered in the mode active at theme load, so vi `insert` (where editing happens) fell through to fish's preset `execute`. `fish_{vi,default}_key_bindings` also wipe bindings on profile swap. Now installs across all six modes (`default` / `insert` / `visual` / `replace` / `replace_one` / `paste`) and re-applies via an `--on-variable fish_key_bindings` hook so swaps survive
- Transient flag's `set -e _damin_in_transient` erased only the smallest scope. A universal-scope leak (typo, dotfile import, prior misconfig) survived the per-tick clear and pinned every prompt to the stub forever. Now uses `set -eg` per tick and `set -eU` at theme load to drain pre-existing leaks
- Transient flag-clear lived in `fish_right_prompt`, so a user/plugin override of `fish_right_prompt` never ran the clear and every prompt after the first Enter stuck as the stub. Restructured into a two-phase state machine in `fish_prompt` (`1` → render stub, advance to `2`; `2` → clear, render full); `fish_right_prompt` now only reads the flag. An overridden right prompt renders its own content during the single transient tick but no longer strands state
- Transient stub collapsed the prompt when Enter inserted a newline instead of executing (open quote, unfinished `for` / `if`, line continuation). The first edit-line briefly turned into `✿`, looking corrupted. Now gates on `commandline --is-valid != 2` so incomplete buffers skip the transient step and the original prompt stays visible while editing
- Fisher install copied `functions/fish_prompt.fish` and `functions/fish_right_prompt.fish` into `~/.config/fish/functions/`, which OMF treats as a "Conflicting prompt setting" and refuses to activate — so Fisher → OMF without `fisher remove` first left the user stuck. The prompt definitions now live in `conf.d/damin.fish` and the `functions/` copies are removed, so fisher no longer deposits a prompt file in the autoload dir. `fisher update` cleans up the stale paths from old installs automatically

### Changed

- Battery percent (`theme_damin_show_battery`) now resolves per-platform via `switch (uname)` — macOS `pmset`, Linux sysfs, FreeBSD / OpenBSD / NetBSD / DragonFly `apm -l` with `sysctl hw.acpi.battery.life` fallback. Previously non-Darwin BSDs fell through to the Linux sysfs path
- Minimum fish version bumped from 3.6 to 3.7 to use the `path mtime` builtin (the cache-freshness check would otherwise need two `stat` forks per prompt)

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
