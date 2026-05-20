# minimal subset the async git-refresh subshell sources. keep small — every
# line here is parse cost on each background fork. conf.d auto-load is
# alphabetical so this loads before damin.fish; damin.fish also sources it
# explicitly for direct `source conf.d/damin.fish` (tests, dev).

set -q _damin_cache_dir; or set -g _damin_cache_dir "$HOME/.cache/damin"

# defaults the subshell reads — rest of theme_damin_* lives in damin.fish.
set -q theme_damin_show_git_op; or set -g theme_damin_show_git_op 1
set -q theme_damin_git_count_untracked; or set -g theme_damin_git_count_untracked 1

set -q _damin_pwd_key_pwd; or set -g _damin_pwd_key_pwd ""
set -q _damin_pwd_key_value; or set -g _damin_pwd_key_value ""

function _damin_pwd_key
    if test "$_damin_pwd_key_pwd" != "$PWD"
        set -g _damin_pwd_key_pwd "$PWD"
        set -g _damin_pwd_key_value (string replace -a / % -- "$PWD")
    end
    echo $_damin_pwd_key_value
end

function _damin_cache_path --argument-names key
    echo "$_damin_cache_dir/"(_damin_pwd_key)"-$key"
end

function _damin_write_cache --argument-names cache_file pwd
    mkdir -p (path dirname $cache_file) 2>/dev/null
    set -l tmp "$cache_file.tmp.$fish_pid"
    printf '%s\n' "$pwd" $argv[3..] >$tmp 2>/dev/null
    mv $tmp $cache_file 2>/dev/null
end

function _damin_git_compute
    # --no-optional-locks: don't wait on another git's index.lock.
    set -l info (command git --no-optional-locks rev-parse --is-inside-work-tree --git-dir --git-common-dir 2>/dev/null)
    test "$info[1]" = true; or return
    set -l git_dir $info[2]
    set -l git_common $info[3]

    set -l branch
    set -l oid
    set -l has_upstream 0
    set -l untracked 0
    set -l modified 0
    set -l staged 0
    set -l ahead 0
    set -l behind 0
    set -l conflict 0

    # -uno: skip the workdir walk for untracked files (30-100x faster in big repos).
    set -l untracked_flag --untracked-files=all
    test "$theme_damin_git_count_untracked" = 0; and set untracked_flag --untracked-files=no
    for line in (command git --no-optional-locks status --porcelain=v2 --branch $untracked_flag 2>/dev/null)
        switch (string sub -l 1 -- "$line")
            case '\?'
                set untracked (math $untracked + 1)
            case u
                set conflict (math $conflict + 1)
            case 1 2
                set -l xy (string sub -s 3 -l 2 -- "$line")
                test (string sub -s 1 -l 1 -- "$xy") != .; and set staged (math $staged + 1)
                test (string sub -s 2 -l 1 -- "$xy") != .; and set modified (math $modified + 1)
            case '#'
                set -l parts (string split ' ' -- "$line")
                switch $parts[2]
                    case branch.head
                        set branch $parts[3]
                    case branch.oid
                        set oid $parts[3]
                    case branch.upstream
                        set has_upstream 1
                    case branch.ab
                        set ahead (string sub -s 2 -- $parts[3])
                        set behind (string sub -s 2 -- $parts[4])
                end
        end
    end

    # no upstream → porcelain v2 omits branch.ab; rev-list against remotes to keep ⇡N alive.
    if test $has_upstream = 0 -a "$ahead" = 0
        if test -n "$(command git --no-optional-locks remote 2>/dev/null)"
            set -l unpushed (command git --no-optional-locks rev-list --count HEAD --not --remotes 2>/dev/null)
            string match -rq '^\d+$' -- "$unpushed"; and set ahead $unpushed
        end
    end

    test "$branch" = '(detached)'; and set branch (string sub -l 8 -- $oid)
    test -z "$branch"; and set branch '?'

    set -l stashed 0
    set -l stash_ts 0
    set -l stash_log "$git_common/logs/refs/stash"
    if test -f $stash_log
        set -l stash_lines (command cat $stash_log 2>/dev/null)
        set stashed (count $stash_lines)
        if test $stashed -gt 0
            # reflog format: `<old> <new> <name> <email> <ts> <tz>\t<msg>`.
            # name may contain spaces, so regex out the `<email> ts tz` tail.
            set -l m (string match -r '> ([0-9]+) [+-][0-9]+' -- $stash_lines[-1])
            test (count $m) -ge 2; and set stash_ts $m[2]
        end
    end

    set -l op ""
    if test "$theme_damin_show_git_op" = 1
        if test -d "$git_dir/rebase-merge" -o -d "$git_dir/rebase-apply"
            set op rebase
        else if test -f "$git_dir/MERGE_HEAD"
            set op merge
        else if test -f "$git_dir/CHERRY_PICK_HEAD"
            set op pick
        else if test -f "$git_dir/REVERT_HEAD"
            set op revert
        else if test -f "$git_dir/BISECT_LOG"
            set op bisect
        end
    end

    printf '%s\n' "$branch" "$untracked" "$modified" "$staged" "$stashed" "$ahead" "$behind" "$conflict" "$op" "$stash_ts"
end

# compute + write the git cache without rendering. used by warmup + async repaint.
function _damin_git_prefill
    set -l cache_file (_damin_cache_path git)
    set -l data (_damin_git_compute 2>/dev/null)
    test -n "$data"; and _damin_write_cache $cache_file "$PWD" $data
end

# branch keys may contain `/`; sanitize to keep one cache file per (pwd, branch).
function _damin_gh_branch_key --argument-names branch
    string replace -a / % -- "$branch"
end

# silent skip when gh is missing, remote isn't github, or no PR is open.
# output: "<num> <isDraft> <pr-url>"
function _damin_gh_compute --argument-names branch
    type -q gh 2>/dev/null; or return
    set -l remote (command git remote get-url origin 2>/dev/null)
    string match -q '*github.com*' -- $remote; or return
    set -l out (command gh pr view "$branch" --json number,isDraft --jq '"\(.number) \(.isDraft)"' 2>/dev/null)
    test -z "$out"; and return
    set -l owner_repo (string replace -r '^.*github\.com[:/]' '' -- $remote | string replace -r '\.git$' '')
    set -l num (string split ' ' -- $out)[1]
    echo "$out https://github.com/$owner_repo/pull/$num"
end

# "-" = negative cache (no PR); lets TTL gate refetches instead of every prompt.
function _damin_gh_prefill --argument-names branch
    test -n "$branch"; or return
    set -l cache_file (_damin_cache_path gh-(_damin_gh_branch_key $branch))
    set -l data (_damin_gh_compute "$branch" 2>/dev/null)
    test -z "$data"; and set data -
    _damin_write_cache $cache_file "$PWD" "$branch" "$data"
end
