# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **8 more languages** — `dotnet` (`*.csproj` / `*.fsproj`), `swift`, `scala`, `hs` (Haskell), `dart`, `jl` (Julia), `lua`, `cpp` (CMake / meson, label only). 11 → 19 detected languages
- **Nerd Font glyph preset** — `theme_damin_nerd_font=1` swaps the dingbat defaults for Nerd Font icons (needs a patched font). `theme_damin_ascii` still wins, so dumb terminals stay safe
- **Public async-segment API** — `damin_async_refresh <key> <ttl> <command…>` + `damin_async_value <key>` let custom `damin_segment_*` hooks background-fetch, cache, and repaint via the same machinery the built-ins use. `examples/segments/weather.fish` now uses it

### Changed

- **Palette definitions consolidated** — one row per flavor in `_damin_palette_table.fish`; `_damin_palette_{list,data,accents,meta}` derive from it. Adding a palette is now one line instead of four parallel switch arms
- **Defaults consolidated into `_damin_defaults`** — `conf.d/damin.fish` applies them at load and `damin_help` displays them from the same registry, so the two can't drift
- **Fewer prompt forks** — lang version parsing drops a `head` fork per probe; `git status` runs once (not twice) on a cold `cd`; one shared `date +%s` (`_damin_now`) serves relative-time / battery / gh per prompt
- **Azure uses `jq` when available** — accurate `azureProfile.json` parse (BOM-stripped); the string heuristic stays as the no-`jq` fallback
- **`theme_damin_async_repaint` default → `1`** — a warm/stale cache renders immediately (stale-while-revalidate) and a bg `fish -c` triggers a repaint when done; a cold/missing cache computes once synchronously. `=0` restores sync-on-stale
- **Git status refreshes per prompt** — `_damin_git_render` no longer gates on mtime or TTL. `async_repaint=1` kicks a bg refresh every prompt; `async_repaint=0` (or `async_git=0`) recomputes synchronously. Editor-only edits show up on the next prompt without a TTL fallback
- **Async watchdog folded into the worker subshell** — the per-kickoff hang-timeout (`theme_damin_async_timeout`) now runs as an in-worker `begin; sleep N; kill` block, so each kickoff forks once from the prompt instead of twice
- **Root `fish_title.fish` is now a shim** — it sources `functions/fish_title.fish` (single source of truth) instead of duplicating the 43-line body; both are now covered by `tools/lint.sh` / `tools/format.sh`

### Fixed

- **Lang version from the binary fork never rendered** — the fallback used `string match -gr` with no capture group (returns nothing); switched to `-r`. Pin-file versions (`.tool-versions` etc.) were unaffected
- **A non-integer numeric toggle aborted the prompt** — e.g. `theme_damin_branch_max_len=ten` hit `test -gt` and errored; numeric toggles now coerce back to their default at load
- **`theme_damin_show_project_parent` was inverted** — the project-relative `<project>/<rel>` path only rendered when set to `0`, the opposite of its default (`1`) and its documented meaning. Now `1` (default) renders project-relative and `0` shows the abbreviated full PWD
- **Apostrophe in `$PWD` broke the async git segment** — `_damin_async_kickoff` interpolated the cwd (and core path) into single quotes unescaped, so a path like `~/Don't Touch/repo` produced a broken subshell that never wrote the cache, leaving the git segment permanently blank there. Both are now `string escape`d
- **Blank git segment on the first prompt in an un-warmed repo** — under `async_repaint=1` a cold/stale cache returned nothing instead of rendering. `_damin_git_render` now computes once synchronously on a cache miss while the bg kickoff warms the cache for later prompts
- **Async refresh never completed in slow repos / on held Enter** — `_damin_async_kickoff` killed and restarted the in-flight worker every prompt, so when `git status` outran the gap between prompts the refresh never finished and the cache stayed stale until a write-side git command dropped it. It now **skips** (via `kill -0`) while the key's worker is still running, letting it finish

### Removed

- **`theme_damin_git_cache_ttl`** (added in b83ba3a, never released) — superseded by per-prompt refresh

## [1.3.0] - 20260521074146 KST

### Added

- **Shell/remote context indicators** — `theme_damin_show_wsl` (`wsl:<distro>`), `_show_codespaces` (`cs`), `_show_devcontainer` (`devc` via `$REMOTE_CONTAINERS` / `$DEVCONTAINER_CLI`), `_show_tmux` (`tmux:<window>` — cached by `$TMUX_PANE`, 1 fork per pane switch), `_show_zellij` (`zj:<session>`). All opt-in
- **Nix-run / NIX_SHELL_DIR fallback** — env segment surfaces `(nix-run)` from `$IN_NIX_RUN` and `(nix:<dir>)` from `$NIX_SHELL_DIR` when `IN_NIX_SHELL` is unset
- **`theme_damin_right_segments`** — list-typed order control for the right prompt. Tokens: `cwd lang devops env battery duration date extra` (default) + any `damin_segment_<name>`. Drop or reorder; custom hooks slot in directly
- **`damin_palette_preview <flavor>`** — render a sample prompt in `<flavor>` (or `--all`) without applying. Side-by-side flavor comparison for picking
- **`high-contrast` palette** — WCAG AAA-ish dark theme: pure-black bg, saturated foregrounds, lifted overlays. 18 -> 19 flavors
- **`damin_bench --cold`** — wipe `~/.cache/damin` between samples, N=1, no warmup. Surfaces cold-path regressions (first `cd` into a repo, first version-pin read)
- **`damin_bench --compare BASE.json HEAD.json`** — diff two `--json` outputs, emit Δ ms / % per segment + p50 sum. Needs `python3` (already required by bench)
- **`damin_doctor --fix`** — auto-resolves safe items: orphan `fish_prompt.fish` symlink, leaked universal `_damin_in_transient`, missing cache dir
- **Issue auto-link in branch name** — `theme_damin_issue_url_template` (e.g. `https://jira.example.com/{key}`). Branches matching `[A-Z]+-[0-9]+` get wrapped in OSC 8 hyperlinks
- **Stash relative age (`theme_damin_stash_age=1`)** — appends `·2h` / `·3d` / `·now` after `$N`, dim. Reads newest entry from `.git/logs/refs/stash` (no fork)
- **jj counts (`theme_damin_jj_counts=1`)** — modified / added / conflict counts from `jj diff --summary -r @`. 1 fork per prompt; off by default
- **hg dirty bit (`theme_damin_hg_dirty=1`)** — one `hg status -q` fork, first line consumed via the `read` builtin; renders the modified glyph instead of sparkle when the working copy is dirty. No counts
- **`examples/segments/`** — drop-in `damin_segment_*` hooks: `uptime` (60 s TTL), `todo` (TODO/FIXME count per repo), `weather` (async wttr.in). See `examples/segments/README.md`
- **`damin_help --json` / `damin_doctor --json`** — machine-readable output. `damin_help` emits `{name, value, default, set}` per toggle (filter applies); `damin_doctor` emits `{check, status, detail}` per check
- **`damin_config edit`** — open `$EDITOR` on the current export, validate via `fish -n` on save, wipe existing `theme_damin_*` universals, re-source. Syntax errors leave the tmp file in place and abort
- **`damin_doctor` extra checks** — `notify-send` availability when `theme_damin_notify_long_command=1`; `gh` cli + `gh auth status` when `theme_damin_show_gh_pr=1`; kubeconfig file readable when `theme_damin_show_k8s_context=1`; async-signal capture warning when `theme_damin_async_signal` changed after the handler was bound (requires `exec fish`)
- **`_damin_palette_meta`** — flavor -> display name / description / theme (dark|light). `damin_install_themes` and the `damin_set_palette` completion now read from this single source. Combined with `_damin_palette_list` / `_damin_palette_data`, a new palette touches one arm in each instead of five parallel switches
- **`_damin_palette_data` / `_damin_palette_list`** — single source for the palette hex values and canonical flavor name list. Conf.d apply-colors / `damin_install_themes` / `damin_set_palette` / `damin_config` picker all read from these. `conf.d/damin.fish`: 1599 -> 1349 lines (-16%)
- **`damin_uninstall_themes`** — inverse of `damin_install_themes`. Globs `Damin *.theme`, removes after `y/N` confirm
- **`damin_profile --json`** — mirrors `damin_bench --json` for CI comparison
- **`damin_help <PATTERN>`** — substring-filters `theme_damin_*` rows (`damin_help git`). Bare invocation unchanged
- **Palette swatch in `damin_config` picker** — each flavor shows `✿ ❥` in its brand primary/secondary. Extracted to `_damin_palette_accents` helper
- **`damin_doctor` signal collision + VSCode checks** —
  - lists non-damin handlers on `$theme_damin_async_signal` (fzf/atuin/tmux plugins binding SIGUSR1 collide invisibly otherwise)
  - flags `$TERM_PROGRAM=vscode` since VSCode injects its own OSC 633/133
- **OSC 8 clickable hyperlinks** — PR badge `#N` links to its GitHub PR; right-prompt cwd links to `file://<host><path>`. Gated by `theme_damin_osc_integration`
- **Light/dark palette auto-swap** — `theme_damin_palette_light` (unset by default). On theme load, if `$COLORFGBG`'s bg slot ≥ 7, the light palette wins. Terminals that don't set `COLORFGBG` (Alacritty/Kitty/most modern) won't trigger
- **Colorblind-safe palette** — `colorblind` flavor based on the Okabe-Ito 8-color set. Brand accents: sky blue `#56B4E9` + orange `#E69F00`. `.theme` file ships. 17 -> 18 flavors
- **Transient stub distinction** — collapsed prompts render dim instead of bold; `theme_damin_glyph_transient` (defaults to `theme_damin_glyph_prompt`) overrides the stub glyph
- **Async watchdog** — `theme_damin_async_timeout` (default `5`s, `0` disables). Every `_damin_async_kickoff` spawns a `sleep N; kill $bg_pid` so a hung `gh pr view` or k8s YAML walk can't linger
- **Tab completions** — new `completions/` directory with one file per `damin_*` command. Flavor names, subcommands, and currently-set toggle names complete on `<Tab>`. Fisher auto-installs; for OMF, `conf.d/damin.fish` pushes the dir onto `$fish_complete_path`
- **`--help` / `-h` on every `damin_*` command.** Shared formatter in `functions/_damin_help_block.fish`
- **`damin_config` subcommands** — wizard is no longer the only entrypoint:
  - `damin_config` / `damin_config wizard` -> interactive wizard (unchanged)
  - `damin_config get [PATTERN]` -> print matching `theme_damin_*` (substring filter)
  - `damin_config set VAR VALUE...` -> `set -U` after `theme_damin_*` prefix validation; multi-arg -> list-typed value
  - `damin_config reset [PATTERN]` -> list + erase matching universals after `y/N` confirm
  - `damin_config export` -> dump every `theme_damin_*` universal as a runnable fish script. Scope-aware via `set --show` so a `set -g` shadow from conf.d can't leak into the dump
- **Cloud label truncation** — long ARN-style k8s contexts / AWS profiles / GCP projects / Azure subscriptions clip with `…`:
  - `theme_damin_cloud_max_len` — umbrella (default `0` = no limit)
  - `theme_damin_k8s_max_len` / `_aws_max_len` / `_gcp_max_len` / `_azure_max_len` — per-segment; `>0` wins over the umbrella
  - clips the long part only — namespace / region untouched
- **6 new palettes** — `base16`(+`-light`), `zenburn`, `gruvbox-light`, `terminal-dark`/`-light`. Terminal variants use fish's 16-color names (inherit terminal palette); the other four ship hex. 11 -> 17 flavors. `.theme` files generated for the hex flavors
- **`theme_damin_show_date`** + `_date_format` (default `%H:%M`) + `_date_timezone` — right-prompt clock. 1 `date` fork/prompt
- **`theme_damin_default_user`** — when `$USER` matches, suppressed in context + title. Lets `show_user=always` hide your own name while still surfacing other users
- **`theme_damin_branch_max_len`** — truncate long branch names to N chars with `…` (0 = no limit)
- **Project-relative path** — `theme_damin_show_project_parent=0` renders `<project>/<rel>` instead of full PWD inside a repo. `_project_dir_length > 0` abbreviates the rel part. Skipped in git worktrees
- **AWS Vault** — `$AWS_VAULT` surfaces as `aws-vault:<profile>` (distinct from plain `aws:`). Also used as the profile when `$AWS_PROFILE` is unset
- **Fossil VCS** — `theme_damin_show_fossil=1`. Branch via `fossil branch current` (1 fork/prompt). Detected after `.hg/`
- **Context indicators** — `show_screen` (`$STY`), `show_sudo_user` (`$SUDO_USER`), `show_docker_machine` (`$DOCKER_MACHINE_NAME`). All opt-in
- **`damin_colors` hook** — user function called once at theme load; overrides any `_damin_c_*` for per-segment colors beyond the two-accent model
- **`theme_damin_vcs_ignore_paths`** — glob list. Matching `$PWD` short-circuits `_damin_detect_vcs`. For NFS / huge external volumes
- **`solarized` + `solarized-light` palettes** — accents map to `268bd2` / `d33682`
- **`theme_damin_hide_default_branch`** + **`theme_damin_default_branches`** (`main master trunk`) — hide branch name when on a default branch. Counts / op / sparkle still render
- **Mercurial (`hg`) support** — opt-in via `theme_damin_show_hg=1`. Branch from `.hg/branch`, no `hg` fork, no counts. Detected after `.jj/` / `.git/`
- **SSH-aware `user@host`** — `theme_damin_show_user` / `_show_host` (`no`/`ssh`/`always`, default `ssh`). Replaces the bare `ssh` indicator
- **Global version-manager fallback** — `theme_damin_show_lang_global=1`. Reads `$NVM_BIN`/`$FNM_VERSION_FILE_PATH` (node), `$RBENV_VERSION`/`$rvm_ruby_string`/`$RUBY_VERSION` (rb), `$PYENV_VERSION` (py), `$ASDF_<TOOL>_VERSION`. Zero forks
- **`theme_damin_newline_prompt`** — florette on its own line below the status row
- **Terminal title toggles** — `theme_damin_title_show_user` (`0`/`1`/`ssh`), `_show_path` (`0`/`1`/`short`), `_show_process` (`0`/`1`). Title was empty before
- `theme_damin_async_signal` (default `SIGUSR1`). Override if `SIGUSR1` collides with another tool
- `theme_damin_async_gh_pr` (default `1`). Background-fetch `gh pr view` via the same kickoff/signal path as git; `0` falls back to blocking sync
- `damin_doctor` reports hg, ignore paths, SSH session state

### Changed

- **Oh My Fish install path** — registered in [`oh-my-fish/packages-main`](https://github.com/oh-my-fish/packages-main/pull/215) as `damin`. Install is now `omf install damin && omf theme damin` instead of the GitHub URL form. Update via `omf update damin` (or `omf update` for everything)
- **Async-done IPC: universal var -> POSIX signal.** Subshell signals the parent (`SIGUSR1` by default) on finish instead of writing `_damin_async_repaint_token` universally — drops a `~/.config/fish/fish_variables` write per refresh and stops broadcasting to every fish session. Legacy token is auto-erased on theme load
- **`gh pr view` no longer blocks the prompt.** Same kickoff/signal path as git; result disk-cached per `(pwd, branch)` with `theme_damin_gh_pr_ttl`. First prompt on a new branch has no `#N` until the bg fetch returns
- **Generic `_damin_async_kickoff <key> <fn> [<args>...]`.** Replaces the per-segment kickoff functions (git, gh) with one shared helper. New segments need only a `_damin_<seg>_prefill` in core + one render-side call. Per-segment cancel pid renames `_damin_<seg>_refresh_pid` -> `$_damin_async_pid_<key>`
- SSH detection in context segment now also reads `$SSH_CLIENT` / `$SSH_TTY`
- `damin_set_palette` / `damin_config` / `damin_install_themes` accept the two solarized flavors
- `damin_doctor` font width sanity check now exercises `·` (right-prompt separator) alongside the other glyphs — was the only common prompt glyph missing from the test

### Fixed

- **`damin_reset_cache` now clears every in-memory PWD memo.** Previously git / cwd / duration / AWS / GCP / Azure / GH / OSC memos survived a reset; cloud and gh segments could still serve stale data
- **`damin_set_palette` no longer re-runs cache-prune / transient-bindings / async-warmup on its conf.d re-source.** `_damin_loaded` sentinel gates the one-time bootstrap; re-sources now only refresh palette + `_damin_c_*` escapes

## [1.2.0] - 20260513222728 KST

### Added

- `damin_bench` — per-segment P50/P95/P99 via batched sampling. `damin_bench [N=1000] [--json]`. Complements `damin_profile` (means only)
- `theme_damin_git_count_untracked` (default `1`). `0` passes `-uno` to `git status` — 30-100× faster in big repos ([fish-shell#7705](https://github.com/fish-shell/fish-shell/issues/7705)). Trade-off: `?N` blank
- `--no-optional-locks` on every internal `git` call — prompt never blocks on `.git/index.lock`

### Changed

- **Hot-path in-memory memoization wave.** lang / git / cwd / duration renderers keep PWD-keyed (or `$CMD_DURATION`-keyed) in-process cache. Second prompt onward in the same dir skips disk i/o. M-series Mac: out-of-repo `/tmp` **0.80 -> 0.46 ms (-43%)**, dirty + node **1.28 -> 0.70 ms (-45%)**
  - `_damin_lang_render` — disk cache used to be re-read every prompt; in-memory check now fires first
  - `_damin_git_render` — key: `(PWD, cache-mt, stale=0)`. Postexec deletes the cache file -> cache_mt empty -> forced re-read
  - `_damin_cwd_pretty` — `prompt_pwd` only runs on cd
  - `_damin_duration_format` — `$CMD_DURATION` stable within a prompt cycle
  - `_damin_git_path_mtimes` — one batched `path mtime` call drives both the memo key and the staleness signal
- **Async refresh subshell sources only `conf.d/_damin_async_core.fish` (~3 KB)** instead of the full theme. Main theme `source`s it explicitly so direct `source conf.d/damin.fish` (tests, dev) still works
- **Async kickoff cancels prior in-flight refresh** via tracked `$_damin_git_refresh_pid` + `kill`. Rapid `cd` no longer piles up stale work
- **Cloud / DevOps / battery / jj renderers moved to `functions/`** — autoloaded only when their toggle is on. `conf.d/damin.fish`: 1572 -> 1245 lines (-21%)
- `_damin_context_render` / `fish_right_prompt` gate each renderer on its toggle before calling — disabled segments don't autoload
- Stash count via fish `count` builtin (no `wc -l` fork)
- `uname` cached once per session in `_damin_battery_render`

### Fixed

- `_damin_git_compute` — switched quoting from `case '\?'` to unquoted `case \?`. Both forms reach the glob layer as literal `?` and behave identically; this entry was originally framed as a bug fix on the false premise that `'\?'` matched a 2-char literal — it does not. No behavior change in 1.2.0; the real regression is the bare `'?'` form (see Unreleased)

### Reviewed

- `_damin_git_cache_stale` — already optimal. Single `path mtime` builtin, index first in loop for early stale-return. Splitting would add dispatch overhead

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
- `omf remove` -> `omf install` -> `omf theme <name>` tripped `Conflicting prompt setting` because the orphan `fish_prompt.fish` symlink revived. Fixed via `hooks/install.fish`
- `damin_doctor` false positives — flagged legit OMF symlink as stray and hard-coded the theme name. Now matches against the active theme path
- `_damin_git_compute` parsed porcelain v2 with `case '?'` — fish's glob `?` matched every char, so untracked counted everything and branch / modified / staged / ahead / behind all read as 0. Now uses `case '\?'`
- `⇡` ahead never showed without upstream tracking. Falls back to `git rev-list --count HEAD --not --remotes`
- `theme_damin_show_git_op` toggle was never read — op state (`rebase` / `merge` / …) always rendered. Now gated
- Async git cache went stale on out-of-shell commits (lazygit / IDE plugins / `bash -c`). Now invalidates via `path mtime` on `.git/{index,HEAD,logs/HEAD}`
- `theme_damin_apply_colors=1` clobbered user-customized `fish_color_*` universals. Now only fills in unset
- Transient prompt — vi-mode dead-bind, universal-scope flag leak, overridden `fish_right_prompt` stranded state, incomplete-buffer corruption. All fixed
- Fisher install used to copy `fish_prompt.fish` into autoload dir, which OMF flagged as `Conflicting prompt setting`. Definitions moved to `conf.d/`; `fisher update` cleans up old installs

### Changed

- **Minimum fish version 3.6 -> 3.7** — required for the `path mtime` builtin (cache-freshness without `stat` forks)
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

[Unreleased]: https://github.com/miniex/fish-theme-damin/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/miniex/fish-theme-damin/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/miniex/fish-theme-damin/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/miniex/fish-theme-damin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/miniex/fish-theme-damin/releases/tag/v1.0.0
