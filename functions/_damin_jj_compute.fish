# line 1: bookmark or change-id short.
# lines 2-4 (only when theme_damin_jj_counts=1): modified, added, conflict counts.
function _damin_jj_compute
    set -l info (command jj log -r @ --no-graph --no-pager --color=never --template 'bookmarks.join(",") ++ "|" ++ change_id.short()' 2>/dev/null)
    test -z "$info"; and return
    set -l parts (string split '|' -- $info)
    set -l bookmark $parts[1]
    set -l change $parts[2]
    test -n "$bookmark"; and echo $bookmark; or echo $change

    if test "$theme_damin_jj_counts" = 1
        set -l m 0
        set -l a 0
        set -l c 0
        # `jj diff --summary -r @`: first char per line = M/A/D/C/R. ignore D/R.
        for line in (command jj diff --summary -r @ --color=never 2>/dev/null)
            switch (string sub -l 1 -- $line)
                case M
                    set m (math $m + 1)
                case A
                    set a (math $a + 1)
                case C
                    set c (math $c + 1)
            end
        end
        printf '%s\n%s\n%s\n' $m $a $c
    end
end
