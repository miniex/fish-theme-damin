#!/bin/sh
# lint fish (fish_indent --check + fish -n) and shell scripts (shfmt --diff + shellcheck).
set -e

cd "$(dirname "$0")/.."

missing=
for tool in fish fish_indent shfmt shellcheck; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing="$missing $tool"
    fi
done

if [ -n "$missing" ]; then
    echo "missing required tool(s):$missing" >&2
    echo "install via your package manager (brew/apt/cargo/etc.)" >&2
    exit 1
fi

for f in fish_prompt.fish fish_right_prompt.fish fish_title.fish key_bindings.fish \
    conf.d/damin.fish conf.d/_damin_async_core.fish \
    functions/damin_*.fish functions/_damin_*.fish; do
    fish_indent --check "$f"
    fish -n "$f"
done

shfmt -d -i 4 -ci -bn -s tools/bench.sh tools/format.sh tools/lint.sh tools/test.sh
shellcheck tools/bench.sh tools/format.sh tools/lint.sh tools/test.sh
