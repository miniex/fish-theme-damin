# default subscription name from azureProfile.json.
# jq is the accurate path (BOM stripped — the Azure CLI writes a UTF-8 BOM that
# trips jq); the `},`-split string heuristic is the no-jq fallback. cached by mtime.
function _damin_azure_compute --argument-names file
    test -f $file; or return
    if command -q jq
        set -l n (command cat $file 2>/dev/null | string replace -r '^\x{feff}' '' \
            | command jq -r 'first(.subscriptions[]? | select(.isDefault==true) | .name) // empty' 2>/dev/null)
        test -n "$n"; and echo $n; and return
    end
    set -l data (command cat $file 2>/dev/null | string collect)
    test -z "$data"; and return
    set -l chunks (string split '},' -- $data)
    for chunk in $chunks
        string match -qr '"isDefault"\s*:\s*true' -- $chunk; or continue
        set -l m (string match -r '"name"\s*:\s*"([^"]+)"' -- $chunk)
        test (count $m) -ge 2; and echo $m[2]; and return
    end
end
