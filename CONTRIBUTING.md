# Contributing

Thanks for sending changes. The bar is small but firm: every commit and PR must pass `tools/format.sh` and `tools/lint.sh` cleanly.

## Required tools

Install on your `$PATH` before working on this repo:

- [`fish`](https://fishshell.com/) ≥ 3.0 — provides `fish_indent` and the `-n` syntax check used on prompt files
- [`shfmt`](https://github.com/mvdan/sh) — shell script formatter (for `tools/*.sh`)
- [`shellcheck`](https://www.shellcheck.net/) — shell script linter (for `tools/*.sh`)

Examples:

```bash
# macOS
brew install fish shfmt shellcheck

# Arch
sudo pacman -S fish shfmt shellcheck
```

## Workflow

Before every commit:

```bash
./tools/format.sh   # fish_indent on prompt files; shfmt on the tools scripts
./tools/lint.sh     # fish_indent --check + fish -n + shfmt --diff + shellcheck
./tools/test.sh     # fixture tests: git compute, kubeconfig, env, aws/gcp/azure, OSC 7/133
```

`lint.sh` exits non-zero on any formatting drift or shellcheck finding. `test.sh` exits non-zero if any parser assertion fails. CI / reviewers expect a clean run.

Smoke-test end-to-end after touching any `*.fish`:

```fish
# Fisher
fisher install (pwd)
exec fish

# OR Oh My Fish
ln -sfn (pwd) ~/.local/share/omf/themes/fish-theme-damin   # one-time
omf theme fish-theme-damin                                 # apply
exec fish                                                  # reload to confirm the prompt draws
```

## PR expectations

- Keep changes scoped — one concern per PR.
- Update `README.md` when the prompt layout, color palette, or glyph changes; update `docs/ARCHITECTURE.md` when caching / event flow / file layout changes.
- Respect the dual-manager layout — actual code lives in `conf.d/damin.fish` (helpers, setup) and `functions/*.fish` (user-callable functions); the root `fish_prompt.fish` / `fish_right_prompt.fish` / `key_bindings.fish` are thin shims for Oh My Fish and shouldn't grow logic. `hooks/*.fish` runs only on OMF install/update/uninstall lifecycle events — keep it idempotent and side-effect-free outside the orphan cleanup.
- The two brand accents (`theme_damin_accent_primary` / `theme_damin_accent_secondary`) drive every `_damin_c_*` color. Catppuccin variants pin to the original cherry-blossom `#98ABCC` / `#E890B0`; new palettes should map both accents to palette-native primary/secondary — losing one breaks the tone-on-tone identity. Adding a new palette: extend the switch in `conf.d/damin.fish` (`fish_color_*` block *and* the accent block), the valid list in `damin_set_palette`, and the table + license attribution in `damin_install_themes` / `LICENSES/` / `README.md`.
- New lang in the lang segment: add the project marker + label in `_damin_lang_compute`, append the resolution chain (`.tool-versions` key, `.mise.toml` key, lang-specific pin file if any, binary fork), and add a fixture test in `tools/test.sh`.
- Hot-path changes — include before / after `./tools/bench.sh` numbers in the PR description. `damin_profile` is a quicker per-segment view.

## Commit messages

Follow the prefixes already in `git log`. Shape: `prefix(scope?): description`.

Common prefixes: `feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `tools`.

Rules:

- **Prefix is always lowercase** — `feat:` not `Feat:`.
- **First word after the prefix is always lowercase** — `fix: drop trailing space after flower`, not `fix: Drop trailing space after flower`.
- The rest of the description follows no strict case rule, but prefer lowercase. Reserve uppercase for proper nouns, acronyms, or genuine emphasis.

Examples:

```
feat: add flower symbol to fish_prompt
fix: clear color before rendering right prompt
refactor: hoist hex colors into set_color calls
docs: add README.md
```

Single-line, imperative mood. No trailing period.
