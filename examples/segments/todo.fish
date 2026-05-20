# damin_segment_todo — count TODO/FIXME markers in the current git repo, per-PWD cached.
function damin_segment_todo
    test -n "$_damin_vcs_dir"; or return
    set -q _damin_segment_todo_pwd; or set -g _damin_segment_todo_pwd ''
    set -q _damin_segment_todo_value; or set -g _damin_segment_todo_value 0
    if test "$_damin_segment_todo_pwd" != "$PWD"
        set -g _damin_segment_todo_pwd "$PWD"
        # `git grep -c` lists `<file>:<n>`; sum the n's via fish math.
        set -l total 0
        for line in (command git --no-optional-locks grep -E -I -c '(TODO|FIXME)' 2>/dev/null)
            set -l n (string split -r -m 1 ':' -- $line)[-1]
            string match -rq '^[0-9]+$' -- $n; and set total (math $total + $n)
        end
        set -g _damin_segment_todo_value $total
    end
    set -l n $_damin_segment_todo_value
    test -z "$n" -o "$n" = 0; and return
    echo -n -s " " (set_color --dim) "$theme_damin_glyph_sep todo:$n" (set_color normal)
end
