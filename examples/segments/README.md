# Custom segment examples

Drop any of these into a file under `~/.config/fish/conf.d/` (or paste into `config.fish`), then register the segment name:

```fish
set -U theme_damin_extra_left  uptime
set -U theme_damin_extra_right todo weather
```

Or insert into the right-prompt order directly via `theme_damin_right_segments`:

```fish
set -U theme_damin_right_segments cwd lang todo env duration date
```

Every `damin_segment_<name>` function owns its leading separator / glyph / color. The renderer skips missing functions silently.

## Files

- `uptime.fish` — system uptime, dim, refreshed every 60 s.
- `todo.fish` — count of `TODO` / `FIXME` markers in the current git repo. Cached per-PWD; invalidated on `cd` only.
- `weather.fish` — single-line `wttr.in` snippet. Requires `curl`. Uses the built-in async helpers (`damin_async_refresh` / `damin_async_value`): the fetch runs in the background on a 30 min TTL and the prompt repaints the moment it lands — no blocking. Set `$WEATHER_CITY` to pin a location.
