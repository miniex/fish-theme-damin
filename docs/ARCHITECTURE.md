# Architecture

Detailed reference for fish-theme-damin: every feature, every toggle, the cache layer, and the performance budget.

## Layout

```
conf.d/damin.fish        — defaults, color cache, all _damin_* helpers, postexec hook,
                            transient keybindings, Catppuccin palette apply
functions/
  fish_prompt.fish       — fish_prompt definition
  fish_right_prompt.fish — fish_right_prompt definition
  damin_help.fish        — user command
  damin_doctor.fish      — user command
  damin_reset_cache.fish — user command

fish_prompt.fish         — omf shim: sources conf.d/damin.fish + functions/fish_prompt.fish
fish_right_prompt.fish   — omf shim: sources conf.d/damin.fish + functions/fish_right_prompt.fish
key_bindings.fish        — omf shim: sources conf.d/damin.fish
fish_title.fish          — empty

tools/format.sh          — fish_indent + shfmt
tools/lint.sh            — fish_indent --check + fish -n + shfmt --diff + shellcheck
tools/bench.sh           — 100-iteration hot-loop bench across scenarios
```

### Dual-manager strategy

**Fisher** uses fish's standard autoload paths. On install, fisher copies `conf.d/*.fish` to `~/.config/fish/conf.d/` (sourced at fish startup) and `functions/*.fish` to `~/.config/fish/functions/` (autoloaded on first call). Root-level files are ignored.

**Oh My Fish** sources `fish_prompt.fish`, `fish_right_prompt.fish`, `fish_title.fish`, `key_bindings.fish` from the theme directory at theme-switch time. The root files are minimal shims — each does `source $dir/conf.d/damin.fish` and (for prompts) `source $dir/functions/fish_prompt.fish`. The same code path runs as fisher's, just triggered differently.

The split keeps helpers/state in `conf.d/` and user-callable functions (`fish_prompt`, `damin_*`) in `functions/`, matching fish's idiomatic plugin structure.

## Features

### Left prompt segments (in render order)

1. **Context** — `ssh` (`$SSH_CONNECTION`), `root` (bold red when EUID=0, cached at theme load), `dkr` (`/.dockerenv`), `ctr` (`/run/.containerenv`), `k8s` (`$KUBERNETES_SERVICE_HOST`). Stack with spaces.
2. **VCS** — `jj` if `.jj/` is found before `.git/` while walking ancestors (cached per-PWD), else `git`.
   - **git** — branch name (or detached HEAD short), op state in dim red parens (`(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)`), then meta indicators with counts (`?N` untracked, `$N` stashed, `✗N` modified, `✓N` staged, `⇣N` behind, `⇡N` ahead). When fully clean, a `✧` sparkle replaces the meta block.
   - **jj** — bookmark name (or change-id short). No status counts (yet).
3. **Background-job count** — `&N` when `count (jobs -p)` > 0.
4. **Florette `✿`** — bold pink on success, bold red on the previous command's non-zero exit. Trailing space holds the cursor.
5. **Exit code** — dim red `123` right after the florette on failure.

### Right prompt segments

1. **Heart bullet `❥`** + cwd in cool blue
2. **`· lang:version`** — when a project marker is found within 8 levels up
3. **`· (env)`** — when `VIRTUAL_ENV` / `CONDA_DEFAULT_ENV` / `DIRENV_DIR` is set
4. **`· N%`** — battery percent when below threshold (opt-in)
5. **`· duration`** — last command's elapsed time; bold pink when over the long-command threshold

### Transient prompt

`key_bindings.fish` binds `\r` / `\n` to `_damin_transient_enter` which:

1. Sets `_damin_in_transient`
2. Calls `commandline -f repaint` — fish re-runs `fish_prompt` / `fish_right_prompt` which see the flag and emit a single `✿` (left) / nothing (right). `fish_right_prompt` also clears the flag on the way out.
3. Calls `commandline -f execute` — the command runs, output flows below the now-minimal past prompt.
4. The next prompt cycle sees no flag, renders fully.

The flag is cleared in `fish_right_prompt`'s render so empty-Enter still falls back cleanly.

## Configuration

Every toggle is a fish universal variable (`set -U …` persists across sessions, `set -g …` is session-only). Defaults are applied at theme load only when the variable is unset. Run `damin_help` to see all current values.

### Toggles

| Variable                             | Default | Effect                                                            |
|--------------------------------------|---------|-------------------------------------------------------------------|
| `theme_damin_show_git`               | `1`     | Branch + meta on the left (also gates jj)                         |
| `theme_damin_show_jj`                | `1`     | Use jj when `.jj/` is encountered before `.git/`                  |
| `theme_damin_show_git_op`            | `1`     | `(rebase)` / `(merge)` / `(pick)` / `(revert)` / `(bisect)` state |
| `theme_damin_show_context`           | `1`     | `ssh` / `root` / `dkr` / `ctr` / `k8s` indicators                 |
| `theme_damin_show_jobs`              | `1`     | `&N` background-job count                                         |
| `theme_damin_show_env`               | `1`     | `(.venv)` / `(conda)` / `(direnv)` indicator                      |
| `theme_damin_show_lang`              | `1`     | Project language + version                                        |
| `theme_damin_show_battery`           | `0`     | Battery % when ≤ threshold (opt-in — laptops only)                |
| `theme_damin_show_duration`          | `1`     | Last command duration                                             |
| `theme_damin_show_exit_code`         | `1`     | Exit code next to the florette on failure                         |
| `theme_damin_git_counts`             | `1`     | Show counts next to git indicators (`?3 ✓5` vs `? ✓`)             |
| `theme_damin_transient`              | `1`     | Collapse past prompts to `✿` after Enter                          |
| `theme_damin_async_git`              | `1`     | Cache git status + postexec invalidation. `0` = pure sync         |
| `theme_damin_async_lang`             | `1`     | Cache lang detection + postexec invalidation. `0` = sync          |
| `theme_damin_cwd_keep`               | `3`     | Trailing path segments shown in full                              |
| `theme_damin_cwd_short`              | `4`     | Character length each earlier segment is truncated to             |
| `theme_damin_long_command_threshold` | `3000`  | Duration (ms) above which the right-prompt time renders bold      |
| `theme_damin_battery_threshold`      | `30`    | Show battery only when `%` is at or below this number             |
| `theme_damin_ascii`                  | `0`     | Swap every glyph default to ASCII for fonts missing dingbats      |

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

Pure-sync mode (`theme_damin_async_git 0` / `theme_damin_async_lang 0`) skips the cache layer entirely and runs the underlying compute on every prompt.

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

## Notes

- **Lang detection is first-match-wins** in the order `rust → node → go → python → deno`. Polyglot projects pick whichever marker appears highest in the file-system walk (up to 8 levels). Result is cached per-PWD.
- **`jj` support is minimal** — bookmark or change-id short only. No detailed diff counts (yet).
- **Battery is opt-in** because per-platform reads cost a few ms per refresh window — `pmset` on macOS, `/sys/class/power_supply/BAT*/capacity` on Linux, `apm -l` with `sysctl hw.acpi.battery.life` fallback on FreeBSD / OpenBSD / NetBSD / DragonFly. 60 s in-process TTL keeps the work off the hot path, but the segment is off by default for users who don't have a battery to show.
- **Cwd truncation** uses fish's `prompt_pwd --dir-length=N --full-length-dirs=K`. Last K segments stay full; earlier ones truncate to N chars. Defaults (K=3, N=4) are gentle — `~/Documents/projects/foo` stays full, `~/.config/nvim/lua/plugins/lsp` becomes `~/.co/nvim/lua/plugins/lsp`.
- **No Nerd Font dependency** — the two prompt glyphs (`✿` U+273F, `❥` U+2765) live in the Dingbats block (U+2700-U+27BF). The git indicators (`✗` ✓ `⇣` `⇡`) are also Dingbats / Arrows. East Asian Width = Neutral, so they render narrow (1 cell) in any monospace font that covers Dingbats — D2Coding, JetBrains Mono, SF Mono, DejaVu Sans Mono, etc. Some Linux defaults (e.g. older Liberation Mono, Ubuntu Mono builds, Hack without symbol fallback) are missing the dashed arrows `⇡ ⇣` (U+21E1 / U+21E3) or `❥`; those terminals show `?` for the missing slots. `set -U theme_damin_ascii 1` is the one-shot fix; `theme_damin_glyph_ahead` / `theme_damin_glyph_behind` lets you keep the rest fancy and swap only the missing two.

## Internals you might want to know

- **Global state** lives under the `_damin_` prefix: color cache (`_damin_c_*`), per-PWD memos (`_damin_vcs_pwd`/`_damin_vcs_value`, `_damin_lang_pwd`/`_damin_lang_value`, `_damin_pwd_key_pwd`/`_damin_pwd_key_value`), the EUID cache (`_damin_is_root`), the battery TTL (`_damin_battery_at`/`_damin_battery_value`), the transient flag (`_damin_in_transient`), and the cache dir (`_damin_cache_dir`).
- **User-facing helpers** are `damin_help`, `damin_doctor`, `damin_reset_cache` — defined at top level in `fish_prompt.fish` so they're always available after the theme loads.
- **No `funcsave`** — the theme never persists anything to `~/.config/fish/functions/`. Uninstall is `omf theme <other> && rm ~/.local/share/omf/themes/damin`.
