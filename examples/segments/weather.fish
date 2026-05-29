# damin_segment_weather — wttr.in snippet, 30 min TTL.
# the async helpers bg-fetch and repaint when the result lands (no blocking).
function damin_segment_weather
    set -l city $WEATHER_CITY
    damin_async_refresh weather 1800 curl -s --max-time 2 "wttr.in/$city?format=%c+%t"
    set -l v (damin_async_value weather)
    test -z "$v"; and return
    echo -n -s " " (set_color --dim) "$theme_damin_glyph_sep $v" (set_color normal)
end
