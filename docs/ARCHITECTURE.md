# Architecture

Full reference: features, toggles, cache layers, performance budget.

## Layout

```
conf.d/
  _damin_async_core.fish   — minimal subset for the async git-refresh subshell.
                              ~3 KB. underscore prefix loads it before damin.fish.
  damin.fish               — defaults, color cache, hot-path renderers, postexec,
                              fish_prompt / fish_right_prompt.
functions/
  damin_{config,help,doctor,profile,bench,set_palette,install_themes,reset_cache}.fish
                            — user-callable commands.
  _damin_help_block         — shared `--help` formatter for every damin_* command.
  _damin_palette_list       — canonical 18-flavor name list. completion file
                              keeps a static copy for per-flavor descriptions.
  _damin_palette_data       — flavor → 14 fish_color_* hex + 1 bg hint. shared
                              by conf.d's apply-colors block and install_themes.
  _damin_palette_accents    — flavor → "primary_hex secondary_hex". used by
                              conf.d and the damin_config palette picker.
  _damin_{aws,gcp,azure}_*  — lazy-loaded cloud renderers (autoloaded when enabled).
  _damin_k8s_*              — kubernetes render + compute + prefill.
  _damin_{devops,pulumi}_*  — terraform / pulumi.
  _damin_battery_render     — battery.
  _damin_date_render        — right-prompt clock (opt-in).
  _damin_jj_*               — jj.
  _damin_hg_render          — mercurial (opt-in).
  _damin_fossil_render      — fossil (opt-in; one `fossil` fork per prompt).
  _damin_lang_global        — env-var-only version-manager fallback.
  fish_title.fish           — terminal title.
completions/
  damin_*.fish              — tab completions for every user-facing command.
                              palette names, subcommands, --help / --json flags.

fish_{prompt,right_prompt,title}.fish, key_bindings.fish
                            — root-level OMF shims. fish_title is duplicated
                              under functions/ so Fisher autoloads it too.

hooks/install.fish         — OMF install hook: drops stale fish_prompt.fish symlink.

tools/format.sh / lint.sh / bench.sh / test.sh
                            — format, lint, latency bench, fixture tests.
```

### Dual-manager strategy

**Fisher** copies `conf.d/*.fish` to `~/.config/fish/conf.d/` (sourced at startup), `functions/*.fish` to `~/.config/fish/functions/` (autoloaded on first call), and `completions/*.fish` to `~/.config/fish/completions/` (lazy-loaded on first tab). Root-level files are ignored.

**Oh My Fish** clones to `~/.local/share/omf/themes/damin/` (the package name registered in `oh-my-fish/packages-main`) and adds it to `$fish_function_path`. OMF doesn't autoload `completions/`, so `conf.d/damin.fish` pushes the theme's `completions/` dir onto `$fish_complete_path` at theme load. Root-level `fish_prompt.fish` / `fish_right_prompt.fish` / `key_bindings.fish` are shims that source `conf.d/damin.fish`.

`fish_prompt` / `fish_right_prompt` live in `conf.d/`, **not** `functions/` — Fisher would otherwise copy them to `~/.config/fish/functions/`, which OMF flags as "Conflicting prompt setting".

`hooks/install.fish` runs on `omf install` and drops the orphan `fish_prompt.fish` symlink that `omf remove` leaves behind (otherwise the next `omf theme <name>` trips the conflict check).

## Features

### Left prompt segments (in render order)

1. **Context** — space-separated. `ssh` (`$SSH_CONNECTION`/`$SSH_CLIENT`/`$SSH_TTY`), `root` (bold red, EUID cached), `sudo:<user>` (`$SUDO_USER`, opt-in), `dkr` (`/.dockerenv`), `ctr` (`/run/.containerenv`), `dm:<machine>` (`$DOCKER_MACHINE_NAME`, opt-in), `screen:<session>` (`$STY`, opt-in), `aws[-vault]:<profile>` / `gcp:<project>` / `az:<subscription>` (opt-in), `k8s:<context>[/<ns>]`. K8s parses `current-context` directly from kubeconfig — pure-fish, mtime-cached. Bare `k8s` when in-pod (`$KUBERNETES_SERVICE_HOST` set, no readable config). `show_user`/`_show_host` upgrade the bare `ssh` indicator to `user@host`; `default_user` hides matching usernames.
2. **VCS** — first match wins: `.jj/` → `git` → `.hg/` (opt-in) → `.fslckout` (opt-in). `theme_damin_vcs_ignore_paths` (glob list) short-circuits the walk for matching PWDs.
   - **git** — branch (or detached SHA), op state `(rebase|merge|pick|revert|bisect)`, then counts: `XN` unmerged (bold red, first), `?N` untracked, `$N` stashed, `✗N` modified, `✓N` staged, `⇣N` behind, `⇡N` ahead. Clean → `✧` sparkle. In a worktree, appends `wt:<name>` after the branch. With `show_gh_pr=1` + github remote, appends `#<num>` (dim if draft). `hide_default_branch=1` drops the branch name on `default_branches` matches; counts/op/sparkle continue. `branch_max_len > 0` truncates long names with `…`.
   - **jj** — bookmark or change-id short. No status counts.
   - **hg** — branch from `.hg/branch` (falls back to `default`). No counts. Honors `hide_default_branch`.
   - **fossil** — branch via `fossil branch current` (1 fork/prompt; SQLite store). No counts. Honors `hide_default_branch`.
3. **Jobs** — `&N` when `count (jobs -p)` > 0.
4. **Florette `✿`** — bold pink on success, bold red on non-zero exit.
5. **Exit code** — dim red after the florette on failure. `theme_damin_show_exit_code`: `number` (default) / `name` (`SIGINT`, `not-found`, …) / `both` / `off`.

### Right prompt segments

1. **Heart bullet `❥`** + cwd in cool blue. With `show_project_parent=0` inside a VCS repo, renders `<project>/<rel>` instead of full PWD; `project_dir_length > 0` abbreviates the rel part.
2. **`· lang:version`** — when a project marker is found ≤ 8 levels up. Version: `.tool-versions` → `.mise.toml` → lang-specific pin (`.python-version`/`.nvmrc`/`.node-version`/`.ruby-version`/`.java-version`) → binary fork. Langs: `rust` / `node` / `go` / `py` / `deno` / `rb` / `java` / `ex` / `php` / `cr` / `zig`. With `show_lang_global=1`, marker-less PWDs fall through to `_damin_lang_global` — env-var lookup of NVM / fnm / rbenv / RVM / chruby / pyenv / asdf shims.
3. **`· tf:<workspace>` / `· pulumi:<stack>`** — `tf:` reads `.terraform/environment` (hides bare `default`). `pulumi:` prefers `$PULUMI_STACK`, else reads `~/.pulumi/workspaces/<proj>-*-workspace.json` iff exactly one matches. Shared pwd-cached walk-up
4. **`· (env)`** — venv basename / conda env / `direnv:<dir>` / `nix:<derivation-name>` (collapses to bare `nix` when generic or `show_nix_name=0`)
5. **`· N%`** — battery when ≤ threshold (opt-in)
6. **`· duration`** — last command time; bold pink past long-command threshold
7. **`· HH:MM`** — clock (opt-in). Format from `theme_damin_date_format` (default `%H:%M`); optional `theme_damin_date_timezone`. 1 `date` fork/prompt

### Transient prompt

`_damin_install_transient_bindings` binds `\r` / `\n` to `_damin_transient_enter` in all six fish modes (`default`, `insert`, `visual`, `replace`, `replace_one`, `paste`) — vi `insert` needs its own bind. An `--on-variable fish_key_bindings` hook re-installs after `fish_{default,vi}_key_bindings` (which wipe all binds on swap).

`_damin_transient_enter`:

1. `commandline --is-valid` returns 2 on incomplete buffers (open quote etc.) → skip the collapse and just execute (Enter inserts a newline anyway).
2. Set `_damin_in_transient=1` (global).
3. `commandline -f repaint` → fish_prompt sees the flag and emits the stub.
4. `commandline -f execute`.

`fish_prompt` owns the flag as a 2-phase state machine: `1` → render stub, advance to `2`; `2` → `set -eg` clear, render full. Right prompt only reads the flag, so a user-overridden right prompt can't strand it.

Theme load runs `set -eU _damin_in_transient` to drain a universal-scope leak (would otherwise survive `set -eg`). `damin_doctor` checks the leak + binding presence.

### Cloud context

All three off by default. Enabled = one file `stat` per prompt.

- **AWS** — reads `AWS_PROFILE` / `AWS_DEFAULT_PROFILE` (skip if neither set). Region: `AWS_REGION` → `AWS_DEFAULT_REGION` → pure-fish INI walk over `~/.aws/config` (or `$AWS_CONFIG_FILE`). Walk caches by `(mtime, profile)` — one `path mtime` per prompt on unchanged config.
- **GCP** — `CLOUDSDK_CORE_PROJECT` short-circuits. Else reads `~/.config/gcloud/active_config`, then `[core] project` from `configurations/config_<name>`. Both mtime-cached.
- **Azure** — `AZURE_SUBSCRIPTION_NAME` / `AZURE_DEFAULTS_SUBSCRIPTION` short-circuit. Else split `~/.azure/azureProfile.json` on `},`, regex out the chunk with `"isDefault": true`. Fragile but stable since Azure CLI 2.x. Mtime-cached.

Invalidation: `_damin_postexec` watches for `aws` / `gcloud` / `az` / `kubectl config` and drops the matching caches — config writes hit same-second mtime, mtime check alone can't catch them.

### Devops segment

`_damin_devops_resolve` walks PWD up (≤ 8 levels) once per cd, finding `.terraform/` and `Pulumi.{yaml,yml}` in one pass. Globals (`_damin_devops_tf` / `_damin_devops_pl`) keyed by `_damin_devops_pwd`. Exits early when both resolve.

- **Terraform** — reads `.terraform/environment` (set by `terraform workspace select`). Hides bare `default`.
- **Pulumi** — `$PULUMI_STACK` wins. Else reads `Pulumi.yaml`'s `name:`, then globs `~/.pulumi/workspaces/<name>-*-workspace.json` for exactly one match. `$PULUMI_HOME` overrides workspace dir.

Postexec invalidates on `terraform` / `tf` / `pulumi`.

### Kubernetes cache layers

Three layers, fastest first:

1. **In-memory** (`_damin_k8s_mt`/`_ctx`/`_ns`) — second prompt onward. Validated by `path mtime` on kubeconfig.
2. **Disk cache** (`~/.cache/damin/cloud-k8s`, `mtime|ctx|ns`) — written by `_damin_k8s_prefill` in the warmup fork; cold-start re-use when on-disk mtime matches live kubeconfig.
3. **Pure-fish YAML walk** (`_damin_k8s_compute`) — last resort. Slow with 50+ contexts; the disk cache avoids hitting this on every cold start.

`damin_reset_cache` clears both.

### Shell integration (OSC 7 + OSC 8 + OSC 133)

Modern terminals (Ghostty, iTerm2, Kitty, WezTerm, VS Code, Win Terminal, Warp) consume these:

- **OSC 7** `\e]7;file://<host><path>\a` — advertises CWD so new tabs/splits/SSH inherit it. Emitted only on `$PWD` change; path is percent-encoded.
- **OSC 8** `\e]8;;<url>\a<text>\e]8;;\a` — clickable hyperlinks. Right-prompt cwd → `file://<host>/<path>`; GitHub PR badge `#N` → `https://github.com/<owner>/<repo>/pull/<N>`. BEL terminator (not `ESC \`) — fish's printf reads `\%` as escape.
- **OSC 133** `\e]133;A/B/C/D;<exit>\a` — semantic prompt markers. `A` = prompt start, `B` = command input start, `C` = preexec, `D` = postexec with exit. Powers "jump to prompt", "select command output", per-command status.

Unsupported terminals silently drop unrecognized sequences (per spec). Toggle: `theme_damin_osc_integration` (default `1`).

In transient mode, `A`/`B` still wrap the collapsed stub so navigation keeps working.

### Long-command notification

Fires when `$CMD_DURATION` > `theme_damin_notify_threshold` (default 30 000 ms):

- **OSC 9** `\e]9;<msg>\a` — universal terminal notification (iTerm2, Konsole, Win Terminal, Warp, …).
- **`notify-send`** — backgrounded fork on Linux/BSD; survives focus loss.

Message: command (≤ 60 chars) + elapsed seconds + exit code. Off by default (`theme_damin_notify_long_command 0`).

### Custom segments

- `set -U theme_damin_extra_left foo bar` — calls `damin_segment_foo` + `damin_segment_bar` after the vi-mode badge, before the florette.
- `set -U theme_damin_extra_right baz` — calls `damin_segment_baz` at the end of right prompt.

Missing functions are silently skipped. The segment owns its leading separator / glyph / color.

```fish
function damin_segment_kube_age
    set -l n (kubectl get pods --no-headers 2>/dev/null | count)
    test $n -gt 0; and echo -n -s " $(set_color --dim)pods:$n$(set_color normal)"
end
set -U theme_damin_extra_left kube_age
```

### TRAMP / dumb terminal auto-detect

If `$TERM = dumb` or `$INSIDE_EMACS` is set, the dumb block runs first and minimizes four toggles (unless user-set):

- `theme_damin_ascii = 1` (no dingbats)
- `theme_damin_transient = 0` (no repaints)
- `theme_damin_osc_integration = 0` (no escape sequences)
- `theme_damin_apply_colors = 0` (no palette mutation)

User-explicit values win via the same `set -q; or set` idiom. `damin_doctor` reports which trigger fired.

## Configuration

Every toggle is a universal var (`set -U`). Defaults apply only when unset. `damin_help` shows current values.

### `damin_config` subcommands

The bare `damin_config` (no args) is still the interactive wizard. The dispatcher also accepts:

| Subcommand                      | Purpose                                                                            |
| ------------------------------- | ---------------------------------------------------------------------------------- |
| `damin_config wizard`           | Same as bare `damin_config`                                                        |
| `damin_config get [PATTERN]`    | Print matching `theme_damin_*`. Pattern is a substring match against the full name |
| `damin_config set VAR VALUE...` | `set -U` after `theme_damin_*` prefix validation. Multi-arg → list-typed value     |
| `damin_config reset [PATTERN]`  | List matching universals, erase after `y/N` confirm                                |
| `damin_config export`           | Dump every `theme_damin_*` universal as a runnable fish script                     |
| `damin_config --help` / `-h`    | Show usage                                                                         |

`export` parses `set --show` and pulls **only the universal-scope value** — a `set -g` shadow (from conf.d defaults) can't leak into the dump. The output is round-trippable: `damin_config export > my-damin.fish; source my-damin.fish` reconstructs the same universals.

### `--help` and tab completion

Every `damin_*` answers `--help` / `-h` via the shared `_damin_help_block`. Completions in `completions/`:

- `damin_set_palette <Tab>` — 18 flavor names with descriptions
- `damin_config <Tab>` — subcommands (`wizard` / `get` / `set` / `reset` / `export` / `help`)
- `damin_config set <Tab>` / `damin_config reset <Tab>` — currently-set `theme_damin_*` universals
- `damin_help <Tab>` — substring of any currently-known `theme_damin_*` name (filter argument)
- `damin_bench --<Tab>` / `damin_profile --<Tab>` — `--help` / `--json`

`damin_help <pattern>` substring-filters the toggle listing (e.g. `damin_help git` shows every `theme_damin_*git*`). Bare invocation dumps everything as before.

### Toggles

| Variable                             | Default   | Effect                                                                     |
| ------------------------------------ | --------- | -------------------------------------------------------------------------- |
| `theme_damin_show_git`               | `1`       | Branch + meta (gates jj / hg too)                                          |
| `theme_damin_show_jj`                | `1`       | Use jj when `.jj/` found before `.git/`                                    |
| `theme_damin_show_hg`                | `0`       | Mercurial — branch from `.hg/branch`. No counts                            |
| `theme_damin_show_fossil`            | `0`       | Fossil — branch via one `fossil` fork per prompt                           |
| `theme_damin_show_git_op`            | `1`       | `(rebase\|merge\|pick\|revert\|bisect)` state                              |
| `theme_damin_hide_default_branch`    | `0`       | Hide branch when in `theme_damin_default_branches`                         |
| `theme_damin_branch_max_len`         | `0`       | Truncate branch name to N chars with `…` (0 = no limit)                    |
| `theme_damin_cloud_max_len`          | `0`       | Umbrella `…`-clip for k8s ctx / aws profile / gcp project / azure sub      |
| `theme_damin_k8s_max_len`            | `0`       | Per-segment override for k8s context (`>0` wins over `_cloud_max_len`)     |
| `theme_damin_aws_max_len`            | `0`       | Per-segment override for AWS profile                                       |
| `theme_damin_gcp_max_len`            | `0`       | Per-segment override for GCP project                                       |
| `theme_damin_azure_max_len`          | `0`       | Per-segment override for Azure subscription                                |
| `theme_damin_show_context`           | `1`       | `ssh` / `root` / `dkr` / `ctr` / `k8s` indicators                          |
| `theme_damin_show_user`              | `ssh`     | `no` / `ssh` / `always` — `$USER` in context segment                       |
| `theme_damin_show_host`              | `ssh`     | `no` / `ssh` / `always` — hostname in context segment                      |
| `theme_damin_default_user`           | _(unset)_ | If set and `$USER` matches, suppress username in context + title           |
| `theme_damin_show_screen`            | `0`       | `screen:<session>` indicator (from `$STY`)                                 |
| `theme_damin_show_sudo_user`         | `0`       | `sudo:<user>` indicator inside a root shell launched via `sudo`            |
| `theme_damin_show_docker_machine`    | `0`       | `dm:<name>` indicator from `$DOCKER_MACHINE_NAME`                          |
| `theme_damin_show_k8s_context`       | `1`       | Append `:<context>` to `k8s`                                               |
| `theme_damin_show_k8s_namespace`     | `0`       | Append `/<namespace>` to `k8s:<context>`                                   |
| `theme_damin_show_jobs`              | `1`       | `&N` background-job count                                                  |
| `theme_damin_show_env`               | `1`       | `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<name>)`                  |
| `theme_damin_show_nix_name`          | `1`       | Show nix devshell name inside `IN_NIX_SHELL`                               |
| `theme_damin_show_lang`              | `1`       | Project language + version                                                 |
| `theme_damin_show_lang_global`       | `0`       | Fallback to active shell version manager when no project pin               |
| `theme_damin_show_battery`           | `0`       | Battery % when ≤ threshold (laptops)                                       |
| `theme_damin_show_duration`          | `1`       | Last command duration                                                      |
| `theme_damin_show_date`              | `0`       | Right-prompt clock — `theme_damin_date_format` + `_date_timezone`          |
| `theme_damin_show_vi_mode`           | `1`       | `[N]`/`[I]`/`[V]`/`[R]` badge (skipped under emacs binds)                  |
| `theme_damin_show_exit_code`         | `number`  | `number` / `name` / `both` / `off`                                         |
| `theme_damin_show_aws`               | `0`       | `aws:<profile>` indicator                                                  |
| `theme_damin_show_aws_region`        | `1`       | Append `@<region>` to AWS                                                  |
| `theme_damin_show_gcp`               | `0`       | `gcp:<project>` indicator                                                  |
| `theme_damin_show_azure`             | `0`       | `az:<subscription>` indicator                                              |
| `theme_damin_show_terraform`         | `1`       | `tf:<workspace>` from `.terraform/environment`                             |
| `theme_damin_show_pulumi`            | `1`       | `pulumi:<stack>` from `$PULUMI_STACK` or workspaces                        |
| `theme_damin_show_gh_pr`             | `0`       | `#<num>` for current branch's open PR (via `gh`)                           |
| `theme_damin_notify_long_command`    | `0`       | OSC 9 + `notify-send` when `CMD_DURATION` > threshold                      |
| `theme_damin_palette`                | `mocha`   | 1 of 18 built-in flavors (see "Palette flavors" below)                     |
| `theme_damin_palette_light`          | _(unset)_ | If set + `$COLORFGBG` bg slot ≥ 7, this palette wins (light-terminal swap) |
| `theme_damin_accent_primary`         | palette   | Brand accent hex (cwd, branch)                                             |
| `theme_damin_accent_secondary`       | palette   | Brand accent hex (florette, meta)                                          |
| `theme_damin_git_counts`             | `1`       | Show counts next to git indicators (`?3` vs `?`)                           |
| `theme_damin_git_count_untracked`    | `1`       | `0` → `-uno` (30-100× faster in big repos, hides `?N`)                     |
| `theme_damin_newline_prompt`         | `0`       | Move the florette to its own line (multi-line prompt)                      |
| `theme_damin_transient`              | `1`       | Collapse past prompts to `✿` after Enter                                   |
| `theme_damin_async_git`              | `1`       | Cache git + postexec invalidation. `0` = sync                              |
| `theme_damin_async_lang`             | `1`       | Cache lang + postexec invalidation. `0` = sync                             |
| `theme_damin_async_warmup`           | `1`       | Background-prefill caches at theme load                                    |
| `theme_damin_async_repaint`          | `0`       | Stale-while-revalidate git via `fish -c` subshell                          |
| `theme_damin_async_gh_pr`            | `1`       | Background-refresh `gh pr view`; `0` = blocking sync                       |
| `theme_damin_async_signal`           | `SIGUSR1` | Signal the async-refresh subshell sends to repaint the parent              |
| `theme_damin_async_timeout`          | `5`       | Seconds before a hung bg subshell is killed by the watchdog. `0` disables  |
| `theme_damin_osc_integration`        | `1`       | Emit OSC 7 + OSC 8 + OSC 133                                               |
| `theme_damin_cwd_keep`               | `3`       | Trailing path segments kept full                                           |
| `theme_damin_cwd_short`              | `4`       | Chars to truncate earlier segments to                                      |
| `theme_damin_long_command_threshold` | `3000`    | Duration (ms) above which time renders bold                                |
| `theme_damin_battery_threshold`      | `30`      | Show battery when `%` ≤ this                                               |
| `theme_damin_gh_pr_ttl`              | `300`     | Seconds the GitHub PR result is cached                                     |
| `theme_damin_notify_threshold`       | `30000`   | Duration (ms) for long-command notification                                |
| `theme_damin_ascii`                  | `0`       | Swap all glyph defaults to ASCII                                           |
| `theme_damin_title_show_user`        | `ssh`     | Terminal title user/host: `0` / `1` / `ssh`                                |
| `theme_damin_title_show_path`        | `1`       | Terminal title path: `0` / `1` (full) / `short`                            |
| `theme_damin_title_show_process`     | `1`       | Append running process name to terminal title                              |
| `theme_damin_date_format`            | `%H:%M`   | `strftime` format string passed to `date +"…"`                             |
| `theme_damin_date_timezone`          | _(unset)_ | Optional `TZ` override (e.g. `UTC`, `America/Los_Angeles`)                 |
| `theme_damin_show_project_parent`    | `1`       | `0` = render `<project>/<rel>` instead of full PWD inside a VCS repo       |
| `theme_damin_project_dir_length`     | `0`       | Abbreviate each segment of the project-relative part to N chars (0 = full) |

### Glyph overrides

Each symbol comes from `theme_damin_glyph_*` — override one without flipping the whole theme to ASCII. User override wins; otherwise the default below switches on `theme_damin_ascii`.

| Variable                      | Default (fancy) | Default (`ascii=1`) | Where it renders                                |
| ----------------------------- | --------------- | ------------------- | ----------------------------------------------- |
| `theme_damin_glyph_prompt`    | `✿`             | `*`                 | Live florette at end of left prompt             |
| `theme_damin_glyph_transient` | `✿`             | `*`                 | Collapsed stub after Enter (defaults to prompt) |
| `theme_damin_glyph_cwd`       | `❥`             | `>`                 | Right-prompt cwd marker                         |
| `theme_damin_glyph_clean`     | `✧`             | `~`                 | Sparkle when working tree is fully clean        |
| `theme_damin_glyph_modified`  | `✗`             | `!`                 | Modified-file count                             |
| `theme_damin_glyph_added`     | `✓`             | `+`                 | Staged-file count                               |
| `theme_damin_glyph_untracked` | `?`             | `?`                 | Untracked-file count (matches porcelain)        |
| `theme_damin_glyph_stashed`   | `$`             | `$`                 | Stash count                                     |
| `theme_damin_glyph_ahead`     | `⇡`             | `^`                 | Ahead-of-upstream count                         |
| `theme_damin_glyph_behind`    | `⇣`             | `v`                 | Behind-upstream count                           |
| `theme_damin_glyph_conflict`  | `X`             | `X`                 | Unmerged-file count (rendered in bold red)      |
| `theme_damin_glyph_sep`       | `·`             | `\|`                | Right-prompt segment separator                  |

Override one at a time:

```fish
set -U theme_damin_glyph_ahead ^
set -U theme_damin_glyph_behind v
```

### Palette

Two brand accents (`primary`, `secondary`) are palette-driven. Catppuccin keeps `#98ABCC` / `#E890B0`; others map to palette-native (Gruvbox blue/purple, Dracula cyan/purple, …). Override via `theme_damin_accent_primary` / `_secondary`.

| Element                        | Color                     |
| ------------------------------ | ------------------------- |
| Branch name / cwd              | `accent_primary`          |
| Meta symbols (`?$✗✓⇣⇡`) / `✧`  | `accent_secondary`        |
| Meta counts / right-prompt `·` | `accent_secondary` (dim)  |
| Florette `✿` on success        | `accent_secondary` (bold) |
| Florette `✿` on failure        | terminal `red` (bold)     |
| Exit code / op state           | terminal `red` (dim)      |
| `root` context indicator       | terminal `red` (bold)     |
| Other context (`ssh`/`dkr`/…)  | `--dim`                   |
| Heart bullet `❥`               | `accent_secondary`        |
| Lang / env / duration          | `--dim`                   |
| Long-command duration          | `accent_secondary` (bold) |
| Battery (≤10%)                 | terminal `red` (bold)     |

Reskins swap both accents together — losing one breaks the tone-on-tone identity.

### Palette flavors

`fish_color_*` (separate from brand accents) is picked via `theme_damin_palette`. Hex values from upstream sources; see `LICENSES/`.

| Flavor            | text     | base accent feel                                                      |
| ----------------- | -------- | --------------------------------------------------------------------- |
| `mocha`           | dark bg  | catppuccin default, warm violet/peach pop                             |
| `macchiato`       | dark bg  | catppuccin, slightly muted vs mocha                                   |
| `frappe`          | dark bg  | catppuccin, softest dark, cooler accents                              |
| `latte`           | light bg | catppuccin light — high-contrast deep colors                          |
| `gruvbox`         | dark bg  | retro groove, warm earth tones                                        |
| `gruvbox-light`   | light bg | gruvbox light hard — same palette, light bg                           |
| `tokyonight`      | dark bg  | downtown-tokyo neon, blue/purple accents                              |
| `rosepine`        | dark bg  | soho-vibe muted rose/pine                                             |
| `nord`            | dark bg  | arctic north-bluish pastels                                           |
| `dracula`         | dark bg  | classic vampire — cyan/purple/pink pop                                |
| `solarized`       | dark bg  | schoonover classic — calibrated neutrals + sat accents                |
| `solarized-light` | light bg | solarized light — paper-pale base                                     |
| `base16`          | dark bg  | chris kempson default-dark — neutral framework                        |
| `base16-light`    | light bg | base16 default-light                                                  |
| `zenburn`         | dark bg  | jani nurminen classic — low-contrast muted greens                     |
| `colorblind`      | dark bg  | Okabe-Ito 8-color set — distinguishable for deuteranopia / protanopia |
| `terminal-dark`   | dark bg  | uses your terminal's 16-color palette (named colors)                  |
| `terminal-light`  | light bg | terminal palette, light foreground                                    |

`damin_set_palette <flavor>` flips the toggle, erases the `fish_color_*` + accent universals, and re-sources conf.d so the apply block re-fills them. `damin_install_themes` writes 16 hex `Damin <Palette>.theme` files into `~/.config/fish/themes/` for `fish_config theme show` (terminal-\* skipped — named colors, no fixed preview). `damin_uninstall_themes` is the paired inverse — confirms before removing.

### Color override hook

For per-segment colors beyond the two-accent model, define `damin_colors`. Runs once at theme load (after defaults), can overwrite any `_damin_c_*`:

```fish
function damin_colors
    set -g _damin_c_branch (set_color cyan -o)
    set -g _damin_c_cwd    (set_color magenta)
end
```

### List-typed toggles

`set -U <var> <items…>` to populate; `set -e <var>` to clear.

| Variable                       | Default             | Effect                                                        |
| ------------------------------ | ------------------- | ------------------------------------------------------------- |
| `theme_damin_default_branches` | `main master trunk` | Hidden branch names when `hide_default_branch=1`              |
| `theme_damin_vcs_ignore_paths` | _(unset)_           | Glob patterns; matching `$PWD` skips `_damin_detect_vcs` walk |

`vcs_ignore_paths` uses fish glob (`*` / `?` / `**`). Matched once per `cd` and cached in `_damin_vcs_value=""`.

```fish
set -U theme_damin_vcs_ignore_paths '/mnt/nfs/*' '/Volumes/External/*'
set -U theme_damin_default_branches main master develop trunk
```

## Cache architecture

### Files

```
~/.cache/damin/<%-encoded-PWD>-git    9 + 1 = 10 lines (branch, 7 counts, op, with PWD as line 1)
~/.cache/damin/<%-encoded-PWD>-lang   2 lines (value, with PWD as line 1)
~/.cache/damin/cloud-k8s              3 lines (kubeconfig mtime, current-context, namespace)
~/.cache/damin/.last-prune            mtime marker for daily prune
```

PWD encoding: `string replace -a / %` — no `shasum` fork, deterministic.

### Invalidation

`_damin_postexec` watches every command:

- **Git cache** — deleted when `git`/`jj`/`hub`/`gh` runs AND it's not a read-only subcommand (`status`/`log`/`diff`/`show`/`blame`/`ls-*`/`rev-*`/`describe`/`name-rev`/`shortlog`/`whatchanged`/`reflog`/`grep`/`ls-remote`/`help`/`version`).
- **Lang cache** — deleted on `nvm`/`fnm`/`asdf`/`mise`/`pyenv`/`rbenv`/`rustup`/`volta`/`conda`. `npm install` etc. don't change runtime version → no invalidation.
- **Devops cache** — cleared on `terraform`/`tf`/`pulumi`.
- **Cloud caches** — cleared on `aws`/`gcloud`/`az`/`kubectl config` (same-second writes evade mtime).

Postexec only fires for commands in this shell. Out-of-shell mutations (lazygit, IDE plugin, another fish session) are caught by `_damin_git_path_mtimes`: one batched `path mtime` on cache + `.git/{index,HEAD,logs/HEAD}` — any git file newer than cache → stale. Filesystem mtime has 1 s resolution, so same-second writes are still covered by the postexec hook for in-shell commands.

### In-memory PWD memo (hot-path shortcut)

Above the disk cache, four renderers keep a per-PWD (or per-input) in-process memo. Second prompt onward in the same dir **doesn't touch disk**:

- `_damin_git_render` — key: `(PWD, cache-mt, stale=0)`. `_damin_git_path_mtimes` already returns cache_mt as `$mt[1]`, so the memo check costs zero extra syscalls. Postexec deletes the cache file → `cache_mt` empty → memo miss → recompute.
- `_damin_lang_render` — key: PWD. Postexec on version-manager commands clears both disk cache and `_damin_lang_pwd`.
- `_damin_cwd_pretty` — key: PWD. Pure presentation.
- `_damin_duration_format` — key: `$CMD_DURATION`. Stable within a prompt cycle, so repaints cost zero math.

Pure-sync mode (`async_git=0` / `async_lang=0`) skips the disk cache, but the in-memory memo still applies — it's what turned 0.80 ms → 0.46 ms out-of-repo on an M-series Mac.

### True async repaint (opt-in)

`theme_damin_async_repaint=1` adds stale-while-revalidate on top of `async_git`:

- Cache miss → render without git segment + kick off background `fish -c`.
- Stale cache → render with stale data + kick off same bg refresh.

On finish, the subshell sends `$theme_damin_async_signal` (default `SIGUSR1`) to its parent; the parent's `--on-signal` handler clears the guard and runs `commandline -f repaint`. Signal delivery is microsecond-scale and only reaches the originating shell — `set -U` would write `~/.config/fish/fish_variables` on every refresh and broadcast to every fish session.

The subshell sources **only** `_damin_async_core.fish` (~5.7 KB / 148 lines), not the full theme (1349 lines).

`&` on a _fish function_ doesn't populate `$last_pid`, but `&` on `fish -c` does — `_damin_async_kickoff <key> <fn> [<args>...]` captures it into `$_damin_async_pid_<key>` and `kill`s the prior pid on the next call with the same key. Most recent intent wins.

Each kickoff also spawns a watchdog (`sleep $theme_damin_async_timeout; kill $bg_pid`) so a hung `gh pr view` or k8s YAML walk can't linger forever. Default timeout `5` seconds; set to `0` to disable.

Used today by `git _damin_git_prefill` (under `theme_damin_async_repaint`) and `gh _damin_gh_prefill <branch>` (under `theme_damin_async_gh_pr`, default on). New segments need only a `_damin_<seg>_prefill` in core + one render-side call.

The gh disk cache key is `<pwd-key>-gh-<branch-key>` with TTL `theme_damin_gh_pr_ttl`; `-` = negative cache.

`--on-signal` captures the signal name at function-define time; changing `$theme_damin_async_signal` needs a shell restart. Override only if `SIGUSR1` collides with another tool.

### Atomicity

Writes via tmp + rename:

```fish
set -l tmp "$cache_file.tmp.$fish_pid"
printf '%s\n' "$pwd" $data > $tmp
mv $tmp $cache_file
```

POSIX `rename(2)` is atomic on same-filesystem. Per-PID tmp suffix prevents concurrent fish sessions from clobbering each other.

### Pruning

`_damin_cache_prune` runs once per theme load, gated by 24h on `.last-prune` mtime. Files older than 7 days deleted via `find -mtime +7 -delete`.

## Performance

`./tools/bench.sh`: 100 hot-loop iterations + 5 warmup across four scenarios. Needs `python3` for sub-second timestamps on macOS.

M-series Mac reference:

```
out-of-repo (/tmp)                       0.46 ms / prompt
git: clean repo                          0.68 ms / prompt
git: 1 untracked + 1 staged              0.69 ms / prompt
git dirty + node project                 0.70 ms / prompt
```

`bench.sh` measures steady state. Cold cost (first cd into a new repo) is higher — measured by `damin_bench` from a fresh PWD.

### Why it's fast

- Colors pre-computed at theme load (`_damin_c_*`)
- EUID + `uname` cached once per session (no per-prompt fork)
- PWD encoded with `string replace` and memoized (no `shasum` fork per cd)
- **In-memory PWD memo on lang/git/cwd** — second prompt in same dir skips disk i/o; postexec invalidates
- **`_damin_duration_format` memoed by `$CMD_DURATION`** — repaints cost zero math
- **`_damin_git_path_mtimes`** batches cache + index + HEAD + logs/HEAD into one `path mtime` call serving both the memo key and the staleness signal
- Cache reads via fish `read` builtin in a loop (no `cat` fork)
- Cloud / DevOps / battery / jj renderers autoload from `functions/` — disabled = zero parse cost
- Async refresh subshell parses ~3 KB core, not the full 1349-line theme
- Stash count via fish `count` builtin (no `wc -l` fork)
- `git --no-optional-locks` everywhere — prompt never blocks on `.git/index.lock`
- Opt-out `-uno` (`theme_damin_git_count_untracked=0`) skips the workdir walk (30-100× faster in monorepos)
- No per-prompt background refresh — only on cd or postexec invalidation
- `fish_indent`-formatted, `fish -n`-clean

### Cold paths

- First `cd` into a new dir — sync `git status --porcelain=v2 --branch` + (if no pin file resolved) one binary fork for `<lang> --version`. Pin-file detection (`.tool-versions`/`.mise.toml`/`.python-version`/`.nvmrc`/`.node-version`/`.ruby-version`/`.java-version`) runs in the same walk-up, so most projects skip the fork. ~30 ms on small repos.
- After a write-side git command — same cost (cache invalidated).

`damin_profile [N] [--json]` — per-renderer mean over N runs (default 20). GNU `date %N` for ns precision, falls back to gdate/python3/perl. `--json` for CI comparison.

`damin_bench [N] [--json]` — per-segment **min / P50 / P95 / P99** via batched sampling. Default `N=1000` (20 batches × 50). `--json` for CI comparison.

Verify hot numbers: `rm -rf ~/.cache/damin; ./tools/bench.sh`.

### Single-call git compute

`_damin_git_compute` issues two git invocations:

1. `git --no-optional-locks rev-parse --is-inside-work-tree --git-dir --git-common-dir` — worktree-safe.
2. `git --no-optional-locks status --porcelain=v2 --branch` — porcelain v2 emits branch name, oid, ahead/behind, and file counts in one pass. No `git symbolic-ref` / `describe` / `rev-parse` calls.

`--no-optional-locks` means a concurrent git holding `.git/index.lock` (lazygit, IDE plugin) never blocks the prompt.

Stash count reads `<git-common-dir>/logs/refs/stash` directly + fish `count` builtin (no `wc -l`). Op state via file existence checks under `<git-dir>` (no fork).

`theme_damin_git_count_untracked=0` → swaps `--untracked-files=all` for `--untracked-files=no`. 30-100× faster in big repos; `?N` count is blank.

One conditional extra call: no upstream → porcelain omits `branch.ab`. With at least one remote, `git rev-list --count HEAD --not --remotes` surfaces `⇡N` for unpushed commits. No remotes → skip (otherwise every commit reads as "ahead of nothing").

## Notes

- **Lang detection is first-match-wins**: `rust → node → go → python → deno → ruby → elixir → php → crystal → zig → java`. Polyglot projects pick the highest marker (≤ 8 levels up). Per-PWD cached. Version: `.tool-versions` → `.mise.toml` → lang pin → binary fork. Pin paths picked closest-PWD-wins. With `show_lang_global=1`, no-marker PWDs fall through to `_damin_lang_global` (env vars only).
- **`jj` support is minimal** — bookmark or change-id short. No diff counts yet.
- **`hg` support is minimal** — branch from `.hg/branch`. No counts (would need an `hg` fork). Opt-in; detected after `.jj/` / `.git/`.
- **`fossil` support is minimal** — branch from `fossil branch current` (1 fork/prompt). No counts. Opt-in; detected after `.hg/`.
- **Battery is opt-in** — per-platform reads cost a few ms: `pmset` (macOS), `/sys/class/power_supply/BAT*/capacity` (Linux), `apm -l` + `sysctl hw.acpi.battery.life` fallback (BSD). 60 s in-process TTL keeps it off the hot path.
- **Cwd truncation** via `prompt_pwd --dir-length=N --full-length-dirs=K`. Defaults K=3, N=4: `~/.config/nvim/lua/plugins/lsp` → `~/.co/nvim/lua/plugins/lsp`.
- **No Nerd Font** — prompt glyphs live in Dingbats (`✿` U+273F, `❥` U+2765) and Arrows blocks. East Asian Width = Neutral → 1 cell wide in any monospace covering Dingbats (D2Coding, JetBrains Mono, SF Mono, DejaVu, …). Some Linux defaults miss `⇡ ⇣` / `❥` → render as `?`. Fix: `set -U theme_damin_ascii 1`, or swap individual glyphs via `theme_damin_glyph_*`.

## Internals you might want to know

- **Global state** lives under `_damin_`:
  - Hot-path memos: `_damin_vcs_*` (vcs detect), `_damin_lang_pwd/_value`, `_damin_git_cached_pwd/_mt/_data`, `_damin_cwd_pwd/_value`, `_damin_duration_ms/_value`, `_damin_devops_*`
  - Async core (lives in `_damin_async_core.fish`): `_damin_pwd_key_*`, `_damin_cache_dir`
  - Caches: `_damin_c_*` (colors), `_damin_is_root`, `_damin_uname`, `_damin_battery_at/_value`, `_damin_k8s_*`, `_damin_aws_*` / `_gcp_*` / `_azure_*`, `_damin_osc_pwd/_host`, `_damin_gh_branch/_value/_at`
  - Flags: `_damin_async_pid_<key>` (per-segment cancel pid; created on first kickoff), `_damin_in_transient`, `_damin_loaded` (one-time-bootstrap gate; `damin_set_palette` re-source skips it)
- **User-facing commands**: `damin_config`, `damin_help`, `damin_doctor`, `damin_profile`, `damin_bench`, `damin_set_palette`, `damin_install_themes`, `damin_uninstall_themes`, `damin_reset_cache` — autoloaded from `functions/`.
- **Warmup** (`_damin_warmup`): one bg fork at theme load runs `_damin_git_prefill` (in git repos) + `_damin_k8s_prefill` (if `show_k8s_context=1`). `&` forks the current shell, so all helpers are inherited.
- **No `funcsave`** — nothing persists to `~/.config/fish/functions/`. Uninstall: `omf theme <other> && rm -rf ~/.local/share/omf/themes/damin`.
