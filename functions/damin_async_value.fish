# public companion to damin_async_refresh: the cached value for <key>, or empty.
# trailing newline (from the captured command) is trimmed.
function damin_async_value --argument-names key
    set -l cache "$_damin_cache_dir/seg-$key"
    test -f $cache; or return
    string collect <$cache | string trim
end
