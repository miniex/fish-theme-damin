# damin_segment_uptime — system uptime via `uptime -p`. 60 s in-process TTL.
function damin_segment_uptime
    set -l now (date +%s)
    set -q _damin_segment_uptime_at; or set -g _damin_segment_uptime_at 0
    set -q _damin_segment_uptime_value; or set -g _damin_segment_uptime_value ''
    if test (math $now - $_damin_segment_uptime_at) -ge 60
        set -g _damin_segment_uptime_at $now
        set -g _damin_segment_uptime_value (command uptime -p 2>/dev/null | string replace -r '^up ' '')
    end
    set -l v $_damin_segment_uptime_value
    test -z "$v"; and return
    echo -n -s " " (set_color --dim) "$theme_damin_glyph_sep up $v" (set_color normal)
end
