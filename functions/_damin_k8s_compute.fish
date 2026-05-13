# collect all blocks first so order of current-context vs contexts: doesn't matter.
function _damin_k8s_compute --argument-names cfg
    set -l current
    set -l in_contexts 0
    set -l block_ns
    set -l block_name
    set -l names
    set -l namespaces

    for line in (command cat $cfg 2>/dev/null)
        set -l m (string match -r '^current-context: *(.*)$' -- $line)
        if test (count $m) -ge 2
            set current (string trim --chars '"' -- $m[2])
            continue
        end

        if string match -q 'contexts:*' -- $line
            set in_contexts 1
            continue
        else if string match -qr '^[a-zA-Z]' -- $line
            if test -n "$block_name"
                set -a names $block_name
                set -a namespaces $block_ns
                set block_name ""
                set block_ns ""
            end
            set in_contexts 0
            continue
        end

        test $in_contexts = 1; or continue

        if test (string trim -- $line) = '- context:'
            if test -n "$block_name"
                set -a names $block_name
                set -a namespaces $block_ns
            end
            set block_ns ""
            set block_name ""
            continue
        end

        set m (string match -r '^    namespace: *(.*)$' -- $line)
        test (count $m) -ge 2; and set block_ns (string trim --chars '"' -- $m[2])

        set m (string match -r '^  name: *(.*)$' -- $line)
        test (count $m) -ge 2; and set block_name (string trim --chars '"' -- $m[2])
    end

    if test -n "$block_name"
        set -a names $block_name
        set -a namespaces $block_ns
    end

    test -z "$current"; and return

    set -l found_ns ""
    for i in (seq (count $names))
        if test "$names[$i]" = "$current"
            set found_ns $namespaces[$i]
            break
        end
    end
    printf '%s\n%s\n' "$current" "$found_ns"
end
