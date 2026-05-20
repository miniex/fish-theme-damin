# output: line 1 = bookmark or change-id short. lines 2..4 (jj_counts=1) = M/A/C.
# fast path on modern jj uses a single `jj log` template with `diff.summary()`;
# older jj omits the `---` sentinel and falls through to the dual-fork branch.
function _damin_jj_compute
    if test "$theme_damin_jj_counts" = 1
        set -l info (command jj log -r @ --no-graph --no-pager --color=never \
            --template 'bookmarks.join(",") ++ "\n" ++ change_id.short() ++ "\n---\n" ++ diff.summary()' 2>/dev/null)
        set -l lines (string split \n -- $info)
        set -l sep_idx (contains -i -- --- $lines 2>/dev/null)
        if test -n "$sep_idx"
            set -l bookmark $lines[1]
            set -l change $lines[2]
            test -n "$bookmark"; and echo $bookmark; or echo $change
            set -l m 0
            set -l a 0
            set -l c 0
            for line in $lines[(math $sep_idx + 1)..]
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
            return
        end
    end

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
