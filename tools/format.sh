#!/bin/sh
# Format fish (fish_indent) and shell scripts (shfmt).
set -e

cd "$(dirname "$0")/.."

missing=
for tool in fish_indent shfmt; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing="$missing $tool"
    fi
done

if [ -n "$missing" ]; then
    echo "missing required tool(s):$missing" >&2
    exit 1
fi

fish_indent -w fish_prompt.fish fish_right_prompt.fish fish_title.fish key_bindings.fish \
    conf.d/damin.fish \
    functions/fish_prompt.fish functions/fish_right_prompt.fish \
    functions/damin_help.fish functions/damin_doctor.fish functions/damin_reset_cache.fish
shfmt -w -i 4 -ci -bn -s tools/bench.sh tools/format.sh tools/lint.sh tools/test.sh
