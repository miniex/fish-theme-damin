# public async helper for custom damin_segment_* hooks.
#   damin_async_refresh <key> <ttl-seconds> <command…>
# if the disk cache for <key> is older than <ttl> (or missing), run <command> in a
# background fish, capture its stdout to the cache, and signal a prompt repaint when
# done. non-blocking — pair with `damin_async_value <key>` in the render path.
# <command> must be self-contained (no theme-internal functions): it runs in a bare
# subshell, not the prompt's. ttl 0 = refresh every prompt.
function damin_async_refresh --argument-names key ttl
    set -l cmd $argv[3..]
    test -n "$key"; and test (count $cmd) -gt 0; or return
    string match -rq '^[0-9]+$' -- "$ttl"; or set ttl 0

    set -l cache "$_damin_cache_dir/seg-$key"
    set -l mt (path mtime $cache 2>/dev/null)
    test -n "$mt"; and test (math (_damin_now) - $mt) -lt $ttl; and return

    # escape everything interpolated into the subshell so spaces / quotes survive.
    set -l esc_cmd (string escape -- $cmd)
    set -l esc_cache (string escape -- $cache)
    set -l esc_tmp (string escape -- "$cache.tmp.$fish_pid")
    set -l parent $fish_pid
    set -l signal $theme_damin_async_signal
    mkdir -p $_damin_cache_dir 2>/dev/null
    fish -c "
        $esc_cmd >$esc_tmp 2>/dev/null
        mv $esc_tmp $esc_cache 2>/dev/null
        kill -s $signal $parent 2>/dev/null
    " >/dev/null 2>&1 &
    disown 2>/dev/null
end
