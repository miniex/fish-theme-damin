# Contributing

Every PR must pass `tools/format.sh` and `tools/lint.sh` clean.

## Required tools

- [`fish`](https://fishshell.com/) ≥ 3.0 — for `fish_indent` and `fish -n`
- [`shfmt`](https://github.com/mvdan/sh) — formats `tools/*.sh`
- [`shellcheck`](https://www.shellcheck.net/) — lints `tools/*.sh`

```bash
brew install fish shfmt shellcheck       # macOS
sudo pacman -S fish shfmt shellcheck     # Arch
```

## Workflow

Before every commit:

```bash
./tools/format.sh   # fish_indent + shfmt
./tools/lint.sh     # fish_indent --check + fish -n + shfmt --diff + shellcheck
./tools/test.sh     # fixture tests
```

All three must exit 0. CI/reviewers expect a clean run.

Smoke-test after touching any `*.fish`:

```fish
# Fisher
fisher install (pwd); exec fish

# Oh My Fish
ln -sfn (pwd) ~/.local/share/omf/themes/damin
omf theme damin; exec fish
```

## PR expectations

- One concern per PR.
- Update `README.md` for layout/palette/glyph changes; `docs/ARCHITECTURE.md` for caching, event flow, or file layout.
- Code lives in:
  - `conf.d/damin.fish` — defaults, color cache, hot-path renderers, postexec, `fish_prompt` / `fish_right_prompt`
  - `conf.d/_damin_async_core.fish` — minimal helpers the async-refresh subshell sources. Keep self-contained; new deps grow the fork cost
  - `functions/damin_*.fish` — user-callable (`damin_config`, `damin_help`, `damin_doctor`, `damin_profile`, `damin_bench`, …). Add a `--help` short-circuit to every new command via `_damin_help_block`
  - `functions/_damin_*.fish` — lazy-loaded segment renderers (aws/gcp/azure/k8s/pulumi/terraform/battery/jj/hg/fossil/date/lang_global) and shared helpers (`_damin_help_block`, `_damin_truncate`, …). New opt-in segments go here
  - `functions/fish_title.fish` — terminal title. Mirror any change into root `fish_title.fish` to keep OMF/Fisher autoload paths consistent
  - `completions/damin_*.fish` — tab completion. One file per user-facing command. Fisher auto-installs; OMF picks them up via `$fish_complete_path` pushed in `conf.d/damin.fish`
  - Root `fish_prompt.fish` / `fish_right_prompt.fish` / `fish_title.fish` / `key_bindings.fish` — OMF shims, no logic
  - `hooks/*.fish` — OMF install lifecycle. Idempotent and side-effect-free outside the orphan cleanup
  - `examples/segments/*.fish` — drop-in `damin_segment_<name>` snippets. Not installed by Fisher/OMF; users copy or symlink into `~/.config/fish/conf.d/`
- Brand accents (`theme_damin_accent_primary` / `_secondary`) drive every `_damin_c_*`. Adding a palette: arm in `_damin_palette_data.fish` (14 `fish_color_*` hex + 1 bg hint), arm in `_damin_palette_accents.fish` (brand pair), arm in `_damin_palette_meta.fish` (display name + description + dark|light), name in `_damin_palette_list.fish`, plus `LICENSES/` + `README.md` highlights count. `damin_set_palette`, the config picker, `damin_install_themes`, and the `damin_set_palette` completion all pick up from those helpers automatically.
- New lang: marker + label in `_damin_lang_compute`, resolution chain (`.tool-versions` -> `.mise.toml` -> lang pin -> binary fork), fixture test in `tools/test.sh`.
- Hot-path changes: include before/after `./tools/bench.sh` numbers. `damin_profile` for means, `damin_bench` for P50/P95/P99. Per-PWD or per-input memo -> document its invalidation path.

## Commit messages

Shape: `prefix(scope?): description`. Prefixes: `feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `tools`.

- Lowercase prefix and first word: `fix: drop trailing space`, not `Fix: Drop trailing space`.
- Rest of description prefers lowercase; uppercase for proper nouns / acronyms.
- Single line, imperative, no trailing period.

```
feat: add flower symbol to fish_prompt
fix: clear color before rendering right prompt
refactor: hoist hex colors into set_color calls
```
