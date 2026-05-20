# damin_segment_weather — wttr.in snippet, 30 min TTL, async bg curl.
# the bg subshell uses `set -U` so every fish session shares the value.
# swap `set -U` -> `set -g` for per-session only.
function damin_segment_weather
    test -z "$WEATHER_CITY"; and set -l WEATHER_CITY ''
    set -q _damin_segment_weather_at; or set -g _damin_segment_weather_at 0
    set -q _damin_segment_weather_value; or set -g _damin_segment_weather_value ''
    set -l now (date +%s)
    if test (math $now - $_damin_segment_weather_at) -ge 1800
        set -g _damin_segment_weather_at $now
        # background refresh — result lands in the next prompt cycle.
        fish -c "
            set -l v (command curl -s --max-time 2 'wttr.in/$WEATHER_CITY?format=%c+%t' 2>/dev/null)
            set -U _damin_segment_weather_value \"\$v\"
        " >/dev/null 2>&1 &
        disown 2>/dev/null
    end
    set -l v $_damin_segment_weather_value
    test -z "$v"; and return
    echo -n -s " " (set_color --dim) "$theme_damin_glyph_sep $v" (set_color normal)
end
