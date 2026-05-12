# Architecture

Detailed reference for fish-theme-damin: every feature, every toggle, the cache layer, and the performance budget.

## Layout

```
conf.d/damin.fish        — defaults, color cache, all _damin_* helpers, postexec hook,
                            transient keybindings, Catppuccin palette apply
functions/
  damin_help.fish        — user command
  damin_doctor.fish      — user command
  damin_reset_cache.fish — user command

fish_prompt.fish         — omf shim: sources conf.d/damin.fish
fish_right_prompt.fish   — omf shim: sources conf.d/damin.fish
key_bindings.fish        — omf shim: sources conf.d/damin.fish
fish_title.fish          — empty

tools/format.sh          — fish_indent + shfmt
tools/lint.sh            — fish_indent --check + fish -n + shfmt --diff + shellcheck
tools/bench.sh           — 100-iteration hot-loop bench across scenarios
tools/test.sh            — fixture-repo assertions for _damin_git_compute
```

### Dual-manager strategy

**Fisher** uses fish's standard autoload paths. On install, fisher copies `conf.d/*.fish` to `~/.config/fish/conf.d/` (sourced at fish startup) and `functions/*.fish` to `~/.config/fish/functions/` (autoloaded on first call). Root-level files are ignored.

**Oh My Fish** clones the theme to `~/.local/share/omf/themes/fish-theme-damin/` and adds it to `$fish_function_path`. The root-level `fish_prompt.fish` / `fish_right_prompt.fish` / `key_bindings.fish` are shims that `source conf.d/damin.fish`; the first `fish_prompt` call autoloads the shim, which loads conf.d and defines both prompt functions.

`fish_prompt` / `fish_right_prompt` live in `conf.d/damin.fish`, **not** in `functions/`. Under `functions/`, fisher would copy them to `~/.config/fish/functions/` — which OMF treats as a "Conflicting prompt setting" and refuses to activate. Keeping them in conf.d makes Fisher ↔ OMF transitions conflict-free. `damin_help` / `damin_doctor` / `damin_reset_cache` stay in `functions/` since OMF doesn't gate on those names.

## Features

### Left prompt segments (in render order)

1. **Context** — `ssh` (`$SSH_CONNECTION`), `root` (bold red when EUID=0, cached at theme load), `dkr` (`/.dockerenv`), `ctr` (`/run/.containerenv`), `aws:<profile>` / `gcp:<project>` / `az:<subscription>` (opt-in, see [Cloud context](#cloud-context) below), `k8s:<context>` (parses `current-context` from `$KUBECONFIG`'s first path or `~/.kube/config`; pure-fish, mtime-cached, no `kubectl` fork; appends `/<namespace>` when `theme_damin_show_k8s_namespace=1`; falls back to bare `k8s` when `$KUBERNETES_SERVICE_HOST` is set but no config is readable, e.g. inside a pod). Stack with spaces.
2. **VCS** — `jj` if `.jj/` is found before `.git/` while walking ancestors (cached per-PWD), else `git`.
   - **git** — branch name (or detached HEAD short), op state in dim red parens (`(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)`), then meta indicators with counts (`?N` untracked, `$N` stashed, `✗N` modified, `✓N` staged, `⇣N` behind, `⇡N` ahead). When fully clean, a `✧` sparkle replaces the meta block. With `theme_damin_show_gh_pr=1` and a github remote, appends `#<num>` for the current branch's open PR (dim when draft).
   - **jj** — bookmark name (or change-id short). No status counts (yet).
3. **Background-job count** — `&N` when `count (jobs -p)` > 0.
4. **Florette `✿`** — bold pink on success, bold red on the previous command's non-zero exit. Trailing space holds the cursor.
5. **Exit code** — dim red `123` right after the florette on failure. With `theme_damin_status_names=1`, `126` → `noexec`, `127` → `not-found`, and `128+N` → signal names (`SIGINT` / `SIGKILL` / `SIGTERM` …) via fish's `fish_status_to_signal` builtin; the raw number stays for codes without a known mapping.

### Right prompt segments

1. **Heart bullet `❥`** + cwd in cool blue
2. **`· lang:version`** — when a project marker is found within 8 levels up
3. **`· (env)`** — when `VIRTUAL_ENV` / `CONDA_DEFAULT_ENV` / `DIRENV_DIR` / `IN_NIX_SHELL` is set. Renders as the venv basename, conda env name, `direnv:<project>` (basename of `$DIRENV_DIR`), or `nix:<name>` (the derivation's `name` attr; collapses to bare `nix` when generic or when `theme_damin_show_nix_name=0`)
4. **`· N%`** — battery percent when below threshold (opt-in)
5. **`· duration`** — last command's elapsed time; bold pink when over the long-command threshold

### Transient prompt

`_damin_install_transient_bindings` binds `\r` / `\n` to `_damin_transient_enter` across all six fish modes (`default`, `insert`, `visual`, `replace`, `replace_one`, `paste`) — a single-mode bind would leave vi `insert` (where editing happens) inert. An `--on-variable fish_key_bindings` hook re-installs after `fish_{default,vi}_key_bindings`, which wipe all bindings on swap.

`_damin_transient_enter`:

1. If `commandline --is-valid` returns 2 (incomplete buffer: open quote, line continuation), skips to step 4 — Enter inserts a newline rather than executing, so collapsing the prompt mid-edit would look corrupted.
2. Sets `_damin_in_transient=1` at global scope (session only).
3. `commandline -f repaint` — `fish_prompt` / `fish_right_prompt` see the flag and emit `✿` (left) / blank (right).
4. `commandline -f execute`.

`fish_prompt` owns the flag as a two-phase state machine: `1` → render stub and advance to `2`; `2` → `set -eg` clear and render full. `fish_right_prompt` only reads the flag, so a user-overridden right prompt can't strand it — trade-off is one tick of the user's right prompt rendering alongside our stub.

`conf.d/damin.fish` runs `set -eU _damin_in_transient` at theme load to drain a universal-scope leak (which would otherwise survive `set -eg` and pin every prompt to the stub). `damin_doctor` checks the same leak plus binding presence in `default` / `insert`.

### Cloud context

All three are off by default — each adds one file `stat` per prompt when enabled.

- **AWS** — reads `AWS_PROFILE` / `AWS_DEFAULT_PROFILE`; if neither is set, the segment skips. Region falls back to `AWS_REGION` / `AWS_DEFAULT_REGION`, then to a pure-fish INI walk over `~/.aws/config` (`$AWS_CONFIG_FILE` overrides). The walk reads only the `[default]` or `[profile <name>]` section that matches and is cached by `(mtime, profile)` so unchanged config files cost one `path mtime` call.
- **GCP** — `CLOUDSDK_CORE_PROJECT` short-circuits. Otherwise reads `~/.config/gcloud/active_config` (one line, the active config name; `CLOUDSDK_CONFIG` overrides the directory), then walks `[core] project` out of `~/.config/gcloud/configurations/config_<name>`. Both files are mtime-cached independently.
- **Azure** — `AZURE_SUBSCRIPTION_NAME` or `AZURE_DEFAULTS_SUBSCRIPTION` short-circuit. Otherwise `~/.azure/azureProfile.json` is read whole and split on `},` into per-subscription chunks; the one containing `"isDefault": true` yields its `"name"` via a single regex. Fragile by spec but the schema has been stable since the Azure CLI 2.x release. Mtime-cached.

Cache invalidation: `_damin_postexec` watches the command line for `aws` / `gcloud` / `az` and drops all three caches — `aws configure`, `gcloud config set`, and `az account set` mutate their files but don't change the mtime in a way the read-time check can predict reliably (same-second writes).

### Shell integration (OSC 7 + OSC 133)

Modern terminals (Ghostty, iTerm2, Kitty, WezTerm, VS Code, Windows Terminal, Warp) expose two features the prompt has to opt into:

- **OSC 7** (`\e]7;file://<host><path>\a`) tells the terminal the current working directory. New tabs / splits / SSH-share-cwd open in the same directory without the shell having to track it. Emitted from `fish_prompt` only when `$PWD` changes (`_damin_osc7_emit` short-circuits on the cached PWD). Path is percent-encoded via `string escape --style=url` on each segment so spaces and non-ASCII survive.
- **OSC 133** (`\e]133;A\a` … `D;<exit>\a`) marks the semantic regions of a shell session: `A` = prompt start, `B` = prompt end (= command input start), `C` = command starts running (fired from `fish_preexec`), `D;<exit>` = command finished with exit code (fired from `fish_postexec`). Terminals use this for "jump to prompt", "select command output", and per-command exit-status surfacing.

Unsupported terminals are required by the OSC spec to silently drop unrecognized sequences, so the only risk is older or strict terminals that bail on the BEL terminator. The toggle (`theme_damin_osc_integration`, default `1`) is the escape hatch.

In transient mode, the `A`/`B` pair still wraps the collapsed stub so navigation features keep working across the scrollback.

### Long-command notification

`_damin_postexec` fires when a command's `$CMD_DURATION` exceeds `theme_damin_notify_threshold` (default 30 000 ms). Two channels:

- **OSC 9** (`\e]9;<msg>\a`) — the closest thing to a universal terminal notification API. Picked up by iTerm2, Konsole, Windows Terminal, Final Term, ConEmu, Warp, and others. Unsupporting terminals print nothing.
- **`notify-send`** — fired in the background (`&`) when the binary is on `$PATH`. Survives focus loss on Linux and BSD desktops.

Message includes the command (truncated to 60 chars), elapsed seconds, and exit code. Off by default (`theme_damin_notify_long_command 0`) — noisy if you frequently run commands that legitimately take longer than the threshold.

### TRAMP / dumb terminal auto-detect

Theme load checks `$TERM = dumb` or `$INSIDE_EMACS` set. If either is true, the dumb block runs *before* the regular default block and sets four toggles to their minimal values *only if the user hasn't explicitly set them*:

- `theme_damin_ascii = 1` (no dingbats)
- `theme_damin_transient = 0` (no terminal repaints — TRAMP/dumb terminals can't render them)
- `theme_damin_osc_integration = 0` (escape sequences leak as literal text)
- `theme_damin_apply_colors = 0` (no palette mutation)

User-explicit `set -U theme_damin_*` values always win because the dumb block uses the same `set -q; or set` idiom. `damin_doctor` reports which trigger fired.

## Configuration

Every toggle is a fish universal variable (`set -U …` persists across sessions, `set -g …` is session-only). Defaults are applied at theme load only when the variable is unset. Run `damin_help` to see all current values.

### Toggles

| Variable                             | Default  | Effect                                                               |
|--------------------------------------|----------|----------------------------------------------------------------------|
| `theme_damin_show_git`               | `1`      | Branch + meta on the left (also gates jj)                            |
| `theme_damin_show_jj`                | `1`      | Use jj when `.jj/` is encountered before `.git/`                     |
| `theme_damin_show_git_op`            | `1`      | `(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)` state    |
| `theme_damin_show_context`           | `1`      | `ssh` / `root` / `dkr` / `ctr` / `k8s` indicators                    |
| `theme_damin_show_k8s_context`       | `1`      | Append `:<context>` to the `k8s` indicator                           |
| `theme_damin_show_k8s_namespace`     | `0`      | Append `/<namespace>` to the `k8s:<context>` indicator (opt-in)      |
| `theme_damin_show_jobs`              | `1`      | `&N` background-job count                                            |
| `theme_damin_show_env`               | `1`      | `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<name>)` indicator  |
| `theme_damin_show_nix_name`          | `1`      | Show the nix devshell's `name` attr when inside `IN_NIX_SHELL`       |
| `theme_damin_show_lang`              | `1`      | Project language + version                                           |
| `theme_damin_show_battery`           | `0`      | Battery % when ≤ threshold (opt-in — laptops only)                   |
| `theme_damin_show_duration`          | `1`      | Last command duration                                                |
| `theme_damin_show_vi_mode`           | `1`      | `[N]`/`[I]`/`[V]`/`[R]` badge — auto-skipped under emacs keybindings |
| `theme_damin_show_exit_code`         | `number` | Enum: `number` / `name` / `both` / `off` (`0`/`1` still accepted)    |
| `theme_damin_show_aws`               | `0`      | `aws:<profile>` context indicator (opt-in)                           |
| `theme_damin_show_aws_region`        | `1`      | Append `@<region>` to the AWS indicator                              |
| `theme_damin_show_gcp`               | `0`      | `gcp:<project>` context indicator (opt-in)                           |
| `theme_damin_show_azure`             | `0`      | `az:<subscription>` context indicator (opt-in)                       |
| `theme_damin_show_gh_pr`             | `0`      | `#<num>` for the current branch's open PR via `gh` (opt-in)          |
| `theme_damin_notify_long_command`    | `0`      | Emit OSC 9 + `notify-send` when CMD_DURATION > threshold             |
| `theme_damin_palette`                | `mocha`  | Catppuccin flavor — `mocha` / `frappe` / `macchiato` / `latte`       |
| `theme_damin_git_counts`             | `1`      | Show counts next to git indicators (`?3 ✓5` vs `? ✓`)                |
| `theme_damin_transient`              | `1`      | Collapse past prompts to `✿` after Enter                             |
| `theme_damin_async_git`              | `1`      | Cache git status + postexec invalidation. `0` = pure sync            |
| `theme_damin_async_lang`             | `1`      | Cache lang detection + postexec invalidation. `0` = sync             |
| `theme_damin_async_warmup`           | `1`      | Background-prefill git cache at theme load when in a repo            |
| `theme_damin_async_repaint`          | `0`      | Stale-while-revalidate git via `fish -c` subshell + repaint signal   |
| `theme_damin_osc_integration`        | `1`      | Emit OSC 7 (cwd advertise) + OSC 133 (semantic prompt markers)       |
| `theme_damin_cwd_keep`               | `3`      | Trailing path segments shown in full                                 |
| `theme_damin_cwd_short`              | `4`      | Character length each earlier segment is truncated to                |
| `theme_damin_long_command_threshold` | `3000`   | Duration (ms) above which the right-prompt time renders bold         |
| `theme_damin_battery_threshold`      | `30`     | Show battery only when `%` is at or below this number                |
| `theme_damin_gh_pr_ttl`              | `300`    | Seconds the cached GitHub PR result is reused before re-fetching     |
| `theme_damin_notify_threshold`       | `30000`  | Duration (ms) above which long-command notification fires            |
| `theme_damin_ascii`                  | `0`      | Swap every glyph default to ASCII for fonts missing dingbats         |

### Glyph overrides

Every prompt symbol is read from a `theme_damin_glyph_*` variable so individual glyphs can be overridden without flipping the whole theme into ASCII mode. Values resolved at theme load: a user-set override wins; otherwise the default is picked from the table below based on `theme_damin_ascii`.

| Variable                         | Default (fancy) | Default (`ascii=1`) | Where it renders                                |
|----------------------------------|-----------------|---------------------|-------------------------------------------------|
| `theme_damin_glyph_prompt`       | `✿`             | `*`                 | Florette at end of left prompt + transient stub |
| `theme_damin_glyph_cwd`          | `❥`             | `>`                 | Right-prompt cwd marker                         |
| `theme_damin_glyph_clean`        | `✧`             | `~`                 | Sparkle when working tree is fully clean        |
| `theme_damin_glyph_modified`     | `✗`             | `!`                 | Modified-file count                             |
| `theme_damin_glyph_added`        | `✓`             | `+`                 | Staged-file count                               |
| `theme_damin_glyph_untracked`    | `?`             | `?`                 | Untracked-file count (matches porcelain)        |
| `theme_damin_glyph_stashed`      | `$`             | `$`                 | Stash count                                     |
| `theme_damin_glyph_ahead`        | `⇡`             | `^`                 | Ahead-of-upstream count                         |
| `theme_damin_glyph_behind`       | `⇣`             | `v`                 | Behind-upstream count                           |
| `theme_damin_glyph_sep`          | `·`             | `\|`                | Right-prompt segment separator                  |

Override one at a time:

```fish
set -U theme_damin_glyph_ahead ^
set -U theme_damin_glyph_behind v
```

### Palette

| Element                        | Color                       |
|--------------------------------|-----------------------------|
| Branch name / cwd              | `#98ABCC` (cool blue)       |
| Meta symbols (`?$✗✓⇣⇡`) / `✧`   | `#E890B0` (warm pink)       |
| Meta counts / right-prompt `·` | `#E890B0` (warm pink, dim)  |
| Florette `✿` on success        | `#E890B0` (warm pink, bold) |
| Florette `✿` on failure        | terminal `red` (bold)       |
| Exit code / op state           | terminal `red` (dim)        |
| `root` context indicator       | terminal `red` (bold)       |
| Other context (`ssh`/`dkr`/…)  | `--dim`                     |
| Heart bullet `❥`               | `#E890B0` (warm pink)       |
| Lang / env / duration          | `--dim`                     |
| Long-command duration          | `#E890B0` (warm pink, bold) |
| Battery (≤10%)                 | terminal `red` (bold)       |

Reskins should swap both anchor colors together — losing one breaks the tone-on-tone identity.

### Catppuccin flavors

The `fish_color_*` block (separate from the two anchor colors above) picks a Catppuccin palette via `theme_damin_palette`. Hex values come straight from `catppuccin/palette` `palette.json`.

| Flavor      | text     | base accent feel                            |
|-------------|----------|---------------------------------------------|
| `mocha`     | dark bg  | default, warm violet/peach pop              |
| `macchiato` | dark bg  | slightly muted vs mocha                     |
| `frappe`    | dark bg  | softest dark, cooler/grayer accents         |
| `latte`     | light bg | the light theme — high-contrast deep colors |

`damin_set_palette <flavor>` flips the toggle, erases the `fish_color_*` universals so the apply block re-fills them, and re-sources the conf.d file. `damin_install_themes` symlinks the four `themes/Damin *.theme` files into `~/.config/fish/themes/` so they appear in `fish_config theme show` and can be applied via the standard fish theming flow.

## Cache architecture

### Files

```
~/.cache/damin/<%-encoded-PWD>-git    8 + 1 = 9 lines (branch, 6 counts, op, with PWD as line 1)
~/.cache/damin/<%-encoded-PWD>-lang   2 lines (value, with PWD as line 1)
~/.cache/damin/.last-prune            mtime marker for daily prune
```

PWD encoding is `string replace -a / %` — no `shasum` fork, deterministic, reversible enough for debugging.

### Invalidation

The `fish_postexec` event handler `_damin_postexec` watches every command:

- **Git cache** — deleted when the command contains `git`/`jj`/`hub`/`gh` AND is not in the read-only whitelist (`status`/`log`/`diff`/`show`/`blame`/`ls-*`/`rev-*`/`describe`/`name-rev`/`shortlog`/`whatchanged`/`reflog`/`grep`/`ls-remote`/`help`/`version`). Read-only commands leave the cache alone — no wasted sync compute on the next prompt.
- **Lang cache** — deleted on version-managing commands only (`nvm`/`fnm`/`asdf`/`mise`/`pyenv`/`rbenv`/`rustup`/`volta`/`conda`). Package installs like `npm install` don't change the active runtime version so they don't trip invalidation.

`fish_postexec` only fires for commands run interactively in this shell, so commits made by `lazygit`, an IDE git plugin, a `bash -c "git commit …"` invocation, or another shell session would leak past the invalidation. `_damin_git_render` adds a second backstop: before reading the cache, it compares the cache mtime against `.git/{index,HEAD,logs/HEAD}` via fish's `path mtime` builtin (one builtin call, no fork). If any git state file is newer than the cache, it's treated as stale and recomputed. Filesystem mtime has 1-second resolution, so commits made within the same second as the cache write are still covered by the postexec hook for in-shell commands and recomputed on the next prompt for everyone else.

Pure-sync mode (`theme_damin_async_git 0` / `theme_damin_async_lang 0`) skips the cache layer entirely and runs the underlying compute on every prompt.

### True async repaint (opt-in)

`theme_damin_async_repaint 1` adds a stale-while-revalidate layer on top of `theme_damin_async_git`:

- Cache miss → render the prompt without the git segment, kick off a backgrounded `fish -c '… _damin_git_prefill'` subshell. When the subshell finishes, it sets `_damin_async_repaint_token` universally, which all listening fish processes pick up via `--on-variable`. The handler clears the in-flight guard and runs `commandline -f repaint`, redrawing the prompt with the now-hot cache.
- Stale cache → render *with* the stale data immediately, kick off the same bg refresh, repaint when ready.

The subshell sources `conf.d/damin.fish` with `_damin_subshell=1` set so the init block (cache prune, transient bindings, warmup) is skipped — only the helper function definitions run.

Universal variables are the only fish IPC primitive that works without a known PID. `&` on a fish function doesn't populate `$last_pid`, so `--on-process-exit` is not an option here.

Only one in-flight refresh is allowed at a time (`_damin_git_refresh_running` guard). The guard clears in the repaint handler.

The repaint event fires in *every* fish shell that has the theme loaded, not just the originator. That's harmless — each shell re-renders its own prompt from its own cache.

### Atomicity

Writes are tmp + rename:

```fish
set -l tmp "$cache_file.tmp.$fish_pid"
printf '%s\n' "$pwd" $data > $tmp
mv $tmp $cache_file
```

POSIX `rename(2)` is atomic on same-filesystem within `~/.cache/damin/`. Readers see either the old file or the new file, never a partial write. Per-PID tmp suffix means concurrent fish sessions can't clobber each other's in-progress writes.

### Pruning

`_damin_cache_prune` runs once per theme load, but only does work if `>= 24h` since the last prune (tracked via `mtime` of `.last-prune` marker). Files older than 7 days are deleted via `find -mtime +7 -delete`.

## Performance

`./tools/bench.sh` runs 100 hot-loop iterations after a 5-iteration warmup, across four scenarios. Requires `python3` for sub-second timestamps (works on macOS without GNU coreutils).

Reference numbers from an M-series Mac:

```
out-of-repo (/tmp)                       0.62 ms / prompt
git: clean repo                          0.89 ms / prompt
git: 1 untracked + 1 staged              0.86 ms / prompt
git dirty + node project                 0.89 ms / prompt
```

### Why it's fast

- All colors pre-computed once at theme load (`_damin_c_*` globals)
- EUID cached at theme load (no `id -u` fork per prompt)
- PWD encoded with `string replace` and memoized (no `shasum` fork per cd)
- Cache reads via fish's `read` builtin in a loop (no `cat` fork)
- No per-prompt background refresh. Refresh only happens on cd-into-new-dir or after a postexec invalidation
- `fish_indent`-formatted, `fish -n`-clean — no parse-time penalty

### Cold paths

- First `cd` into a new directory — sync `git status --porcelain=v2 --branch` + (if a marker is found) one subprocess for `rustc`/`node`/`go`/`python3`/`deno --version`. Typically ~30 ms on small repos, more on large ones.
- After a write-side git command — same cost on the next prompt (cache was invalidated).

To verify: `rm -rf ~/.cache/damin; ./tools/bench.sh` shows hot numbers; the very first call in each scenario is cold but bench warms up before measuring.

### Single-call git compute

`_damin_git_compute` issues one `git rev-parse --is-inside-work-tree --git-dir --git-common-dir` (worktree-safe) and one `git status --porcelain=v2 --branch`. Branch name, oid, ahead/behind, and the four file counts all come out of the porcelain-v2 output — no separate `git symbolic-ref` / `git describe` / `git rev-parse` calls. Stash count reads `<git-common-dir>/logs/refs/stash` directly via `wc -l` (no `git rev-list` fork). Op state is detected by checking file existence under `<git-dir>` (no fork).

One conditional extra call: when the branch has no upstream tracking, porcelain v2 omits `# branch.ab`. In that case (and only when at least one remote exists), `_damin_git_compute` runs `git rev-list --count HEAD --not --remotes` so a fresh feature branch with unpushed commits still surfaces an `⇡N` indicator. Repos with no remotes at all skip this — every commit would otherwise read as "ahead of nothing."

## Notes

- **Lang detection is first-match-wins** in the order `rust → node → go → python → deno`. Polyglot projects pick whichever marker appears highest in the file-system walk (up to 8 levels). Result is cached per-PWD.
- **`jj` support is minimal** — bookmark or change-id short only. No detailed diff counts (yet).
- **Battery is opt-in** because per-platform reads cost a few ms per refresh window — `pmset` on macOS, `/sys/class/power_supply/BAT*/capacity` on Linux, `apm -l` with `sysctl hw.acpi.battery.life` fallback on FreeBSD / OpenBSD / NetBSD / DragonFly. 60 s in-process TTL keeps the work off the hot path, but the segment is off by default for users who don't have a battery to show.
- **Cwd truncation** uses fish's `prompt_pwd --dir-length=N --full-length-dirs=K`. Last K segments stay full; earlier ones truncate to N chars. Defaults (K=3, N=4) are gentle — `~/Documents/projects/foo` stays full, `~/.config/nvim/lua/plugins/lsp` becomes `~/.co/nvim/lua/plugins/lsp`.
- **No Nerd Font dependency** — the two prompt glyphs (`✿` U+273F, `❥` U+2765) live in the Dingbats block (U+2700-U+27BF). The git indicators (`✗` ✓ `⇣` `⇡`) are also Dingbats / Arrows. East Asian Width = Neutral, so they render narrow (1 cell) in any monospace font that covers Dingbats — D2Coding, JetBrains Mono, SF Mono, DejaVu Sans Mono, etc. Some Linux defaults (e.g. older Liberation Mono, Ubuntu Mono builds, Hack without symbol fallback) are missing the dashed arrows `⇡ ⇣` (U+21E1 / U+21E3) or `❥`; those terminals show `?` for the missing slots. `set -U theme_damin_ascii 1` is the one-shot fix; `theme_damin_glyph_ahead` / `theme_damin_glyph_behind` lets you keep the rest fancy and swap only the missing two.

## Internals you might want to know

- **Global state** lives under the `_damin_` prefix: color cache (`_damin_c_*`), per-PWD memos (`_damin_vcs_pwd`/`_damin_vcs_value`, `_damin_lang_pwd`/`_damin_lang_value`, `_damin_pwd_key_pwd`/`_damin_pwd_key_value`), the EUID cache (`_damin_is_root`), the battery TTL (`_damin_battery_at`/`_damin_battery_value`), the k8s mtime cache (`_damin_k8s_*`), cloud-context caches (`_damin_aws_*`, `_damin_gcp_*`, `_damin_azure_*`), the OSC 7 PWD memo (`_damin_osc_pwd`, `_damin_osc_host`), the GitHub PR cache (`_damin_gh_branch` / `_damin_gh_value` / `_damin_gh_at`), the transient flag (`_damin_in_transient`), and the cache dir (`_damin_cache_dir`).
- **User-facing helpers** are `damin_help`, `damin_doctor`, `damin_reset_cache` — defined at top level in `fish_prompt.fish` so they're always available after the theme loads.
- **No `funcsave`** — the theme never persists anything to `~/.config/fish/functions/`. Uninstall is `omf theme <other> && rm -rf ~/.local/share/omf/themes/fish-theme-damin`.
