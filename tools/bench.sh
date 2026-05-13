#!/bin/sh
# prompt latency bench. needs python3 for sub-second timestamps on macOS.
# shellcheck disable=SC2154  # $start/$end are fish vars inside the fish -c body
set -e

cd "$(dirname "$0")/.."
THEME="$(pwd)"

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 required for bench" >&2
    exit 1
fi

bench() {
    label="$1"
    setup="$2"
    fish -c "
        $setup
        source '$THEME/fish_prompt.fish'
        source '$THEME/fish_right_prompt.fish'
        set -g CMD_DURATION 12

        for i in (seq 5)
            fish_prompt >/dev/null
            fish_right_prompt >/dev/null
        end

        set -l start (python3 -c 'import time; print(time.time())')
        for i in (seq 100)
            fish_prompt >/dev/null
            fish_right_prompt >/dev/null
        end
        set -l end (python3 -c 'import time; print(time.time())')
        set -l ms (math \"(\$end - \$start) * 10\")
        printf '  %-38s %6.2f ms / prompt\n' '$label' \$ms
    "
}

echo "=== damin prompt bench (100 iterations, hot cache) ==="
echo

rm -rf "$HOME/.cache/damin"

bench "out-of-repo (/tmp)" "cd /tmp"

BENCH_REPO=$(mktemp -d -t damin-bench.XXXXXX)
cd "$BENCH_REPO"
git init -q
git commit -q --allow-empty -m init

bench "git: clean repo" "cd $BENCH_REPO"

echo new >"$BENCH_REPO/untracked"
touch "$BENCH_REPO/staged"
git -C "$BENCH_REPO" add staged

bench "git: 1 untracked + 1 staged" "cd $BENCH_REPO"

echo '{}' >"$BENCH_REPO/package.json"

bench "git dirty + node project" "cd $BENCH_REPO"

cd "$THEME"
rm -rf "$BENCH_REPO"

echo
echo "(first call in a new PWD is cold; bench measures the steady-state hot loop)"
