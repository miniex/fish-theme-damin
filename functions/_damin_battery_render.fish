function _damin_battery_render
    test "$theme_damin_show_battery" = 1; or return
    set -l now (date +%s)
    if test (math $now - $_damin_battery_at) -ge 60
        set -g _damin_battery_at $now
        # uname is a fork; platform doesn't change mid-session.
        set -q _damin_uname; or set -g _damin_uname (uname)
        set -l pct
        switch $_damin_uname
            case Darwin
                set pct (command pmset -g batt 2>/dev/null | string match -gr '(\d+)%')
                set pct $pct[1]
            case Linux
                for f in /sys/class/power_supply/BAT*/capacity
                    if test -f $f
                        set pct (command cat $f 2>/dev/null | string trim)
                        break
                    end
                end
            case FreeBSD OpenBSD NetBSD DragonFly
                set pct (command apm -l 2>/dev/null | string trim)
                if not string match -rq '^\d+$' -- "$pct"
                    set pct (command sysctl -n hw.acpi.battery.life 2>/dev/null | string trim)
                end
        end
        string match -rq '^\d+$' -- "$pct"; or set pct ""
        set -g _damin_battery_value "$pct"
    end
    set -l pct $_damin_battery_value
    test -z "$pct"; and return
    test $pct -gt $theme_damin_battery_threshold; and return
    set -l color $_damin_c_dim
    test $pct -le 10; and set color $_damin_c_err
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $color "$pct%" $_damin_c_normal
end
