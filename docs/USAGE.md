# Usage

Commands, configuration, and feature reference. For internals (cache layout, async IPC, palette plumbing) see [ARCHITECTURE.md](ARCHITECTURE.md).

## Features at a glance

- **git / jj / hg / fossil** — counts (`X2 ?2 ✗3 ✓1 ⇡N`), op state (`rebase` / `merge` / `pick` / …), worktree (`wt:<name>`), unmerged-first, opt-in `#N` GitHub PR. `theme_damin_jj_counts` for jj diff counts, `theme_damin_hg_dirty` for hg dirty bit, `theme_damin_stash_age` for newest-stash relative time, `theme_damin_issue_url_template` for `[A-Z]+-[0-9]+` -> OSC 8 ticket links. `hide_default_branch`, `branch_max_len` for long names.
- **Context** — `ssh` / `root` / `sudo:<user>` / `dkr` / `ctr` / `dm:<machine>` / `screen:<session>` / `tmux:<window>` / `zj:<session>` / `wsl:<distro>` / `cs` (Codespaces) / `devc` (Devcontainer) / `k8s:<ctx>/<ns>`, opt-in `aws[-vault]:<profile>` / `gcp:<project>` / `az:<subscription>`. SSH-aware `user@host` + `default_user` to hide your own. Pure-fish, no CLI forks (tmux window cached by `$TMUX_PANE`). `theme_damin_cloud_max_len` (+ per-segment overrides) clips long ARN-style labels with `…`.
- **Lang + env** — 19 langs (`rust` / `node` / `go` / `py` / `deno` / `rb` / `java` / `ex` / `php` / `cr` / `zig` / `dotnet` / `swift` / `scala` / `hs` / `dart` / `jl` / `lua` / `cpp`) via pin files first (`.tool-versions` -> `.mise.toml` -> lang-specific pin -> binary fork). `(.venv)` / `(conda)` / `(direnv:<dir>)` / `(nix:<devshell>)`. Opt-in global-version-manager fallback (rbenv / pyenv / NVM / asdf).
- **Terraform / Pulumi** — opt-in `tf:<workspace>` / `pulumi:<stack>`.
- **Path** — abbreviated cwd, optional project-relative (`<project>/<rel>`) mode.
- **Terminal-native** — OSC 7 (cwd advertise) + OSC 8 (clickable PR badge, cwd, branch issue keys) + OSC 133 (semantic prompt markers). Opt-in OSC 9 + `notify-send` long-command alert. Configurable terminal title + right-prompt clock.
- **19 palettes** — Catppuccin x4 + gruvbox(+light) / tokyonight / rosepine / nord / dracula / solarized(+light) / base16(+light) / zenburn / colorblind (Okabe-Ito) / high-contrast / terminal-dark/-light. `theme_damin_palette_light` auto-swaps when `$COLORFGBG` reports a light terminal. Live switch via `damin_set_palette`; preview without applying via `damin_palette_preview`; `damin_colors` hook for per-segment overrides.
- **Transient prompt** — past prompts collapse to a dim `✿` after Enter. `theme_damin_glyph_transient` overrides the stub glyph.
- **Async** — git/lang/gh refresh in a ~3 KB subshell. Warm prompts serve the cache and bg-refresh (`async_repaint=1`); an un-warmed repo computes once synchronously then caches. Each prompt kicks a git refresh (coalesced — one in-flight worker per key), so editor-only edits show up on the next prompt. `async_timeout` (default `5`s) kills runaway bg work.
- **Customizable** — 70+ `theme_damin_*` toggles. `damin_segment_<name>` hooks + `theme_damin_right_segments` for right-prompt ordering. Example hooks (`uptime`, `todo`, `weather`) under [`examples/segments/`](../examples/segments/).
- **vi-mode badge**, **multi-line option** (`newline_prompt`), **ASCII fallback** (`ascii`) + **Nerd Font preset** (`nerd_font`), **TRAMP / dumb auto-minimal**.

## Commands

Every `damin_*` command answers `--help` / `-h`. Tab completions for subcommands, palette names, and flags are auto-installed.

| Command                          | Purpose                                                            |
| -------------------------------- | ------------------------------------------------------------------ |
| `damin_config`                   | Interactive setup wizard                                           |
| `damin_config get [PATTERN]`     | Print matching `theme_damin_*` (substring filter)                  |
| `damin_config set VAR VALUE...`  | `set -U` a `theme_damin_*` var; multi-arg -> list-typed            |
| `damin_config reset [PATTERN]`   | Unset matching universals after `y/N` confirm                      |
| `damin_config export`            | Dump universals as a runnable fish script (dotfile-friendly)       |
| `damin_config edit`              | Open export in `$EDITOR`; validate + re-source on save             |
| `damin_help [PATTERN] [--json]`  | List every toggle, current value, default                          |
| `damin_doctor [--json] [--fix]`  | Environment + install diagnostic; `--fix` auto-resolves safe items |
| `damin_profile [N] [--json]`     | Per-segment mean ms/render                                         |
| `damin_bench [N] [--json] …`     | Per-segment P50/P95/P99. `--cold` / `--compare BASE HEAD`          |
| `damin_set_palette <flavor>`     | Switch palette                                                     |
| `damin_palette_preview <flavor>` | Sample prompt in `<flavor>` (or `--all`) without applying          |
| `damin_install_themes`           | Write `.theme` files into `~/.config/fish/themes/`                 |
| `damin_uninstall_themes`         | Remove the Damin `.theme` files (confirms)                         |
| `damin_reset_cache`              | Wipe on-disk cache + in-memory memos                               |

## Configuration

Every option is a `theme_damin_*` universal variable. `damin_help` lists them all; full reference + palette + cache details in [ARCHITECTURE.md](ARCHITECTURE.md).

```fish
# either way works:
set -U theme_damin_show_jobs 0
damin_config set theme_damin_show_jobs 0
```

Dotfile users capture every override with `damin_config export > ~/dotfiles/damin.fish` and replay via `source`. `damin_config edit` opens the export in `$EDITOR`, then re-sources on save (broken syntax keeps the tmp file).

### Custom segments

```fish
function damin_segment_kube_age
    set -l n (kubectl get pods --no-headers 2>/dev/null | count)
    test $n -gt 0; and echo -n -s " $(set_color --dim)pods:$n$(set_color normal)"
end
set -U theme_damin_extra_left kube_age
# or splice into the right-prompt order:
set -U theme_damin_right_segments cwd lang kube_age env duration
```

`theme_damin_right_segments` reserves these tokens for built-in renderers (custom segments with the same name are shadowed): `cwd`, `lang`, `devops`, `env`, `battery`, `duration`, `date`, `extra`. The `extra` slot fires every `theme_damin_extra_right` function. Pick a different `damin_segment_<name>` if you collide.

For a segment that shells out (network, slow CLI), use the built-in async helpers instead of blocking the prompt:

```fish
function damin_segment_weather
    # bg-fetch on a 30 min TTL; repaints when the result lands.
    damin_async_refresh weather 1800 curl -s --max-time 2 "wttr.in/?format=%c+%t"
    set -l v (damin_async_value weather)
    test -n "$v"; and echo -n -s " $(set_color --dim)$v$(set_color normal)"
end
```

`damin_async_refresh <key> <ttl-seconds> <command…>` caches `<command>`'s stdout per `<key>` and signals a repaint when it returns; `damin_async_value <key>` reads it. The command runs in a bare subshell, so keep it self-contained (no theme-internal functions).

Three ready-made examples live under [`examples/segments/`](../examples/segments/) — copy or symlink into `~/.config/fish/conf.d/`.

## Local hacking

**Fisher**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
fisher install (pwd)/fish-theme-damin
```

**Oh My Fish**

```fish
git clone https://github.com/miniex/fish-theme-damin.git
ln -sfn (pwd)/fish-theme-damin ~/.local/share/omf/themes/damin
omf theme damin
```

After editing any `*.fish`, smoke-test with `exec fish`. PR checklist in [../CONTRIBUTING.md](../CONTRIBUTING.md).
