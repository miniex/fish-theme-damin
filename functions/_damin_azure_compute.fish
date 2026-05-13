# split azureProfile.json on `},` to get per-subscription chunks (schema is flat).
function _damin_azure_compute --argument-names file
    test -f $file; or return
    set -l data (command cat $file 2>/dev/null | string collect)
    test -z "$data"; and return
    set -l chunks (string split '},' -- $data)
    for chunk in $chunks
        string match -qr '"isDefault"\s*:\s*true' -- $chunk; or continue
        set -l m (string match -r '"name"\s*:\s*"([^"]+)"' -- $chunk)
        test (count $m) -ge 2; and echo $m[2]; and return
    end
end
