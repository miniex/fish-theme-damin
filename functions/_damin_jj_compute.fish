function _damin_jj_compute
    set -l info (command jj log -r @ --no-graph --no-pager --color=never --template 'bookmarks.join(",") ++ "|" ++ change_id.short()' 2>/dev/null)
    test -z "$info"; and return
    set -l parts (string split '|' -- $info)
    set -l bookmark $parts[1]
    set -l change $parts[2]
    test -n "$bookmark"; and echo $bookmark; or echo $change
end
