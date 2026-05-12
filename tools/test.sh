#!/bin/sh
# Test _damin_git_compute against fixture git repos.
# Asserts the 8-line stdout: branch, untracked, modified, staged, stashed, ahead, behind, op.
set -e

cd "$(dirname "$0")/.."
THEME="$(pwd)"

if ! command -v fish >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
    echo "fish and git required" >&2
    exit 1
fi

export GIT_AUTHOR_NAME=t
export GIT_AUTHOR_EMAIL=t@t
export GIT_COMMITTER_NAME=t
export GIT_COMMITTER_EMAIL=t@t

PASS=0
FAIL=0
FAILED_NAMES=""

# Trailing `true` ensures fish exit 0 even on non-git pwd, so `set -e` doesn't fire on $().
run_compute() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        ${2:-}
        cd '$1'
        _damin_git_compute
        true
    " 2>/dev/null
}

expect() {
    name="$1"
    actual="$2"
    expected="$3"
    if [ "$actual" = "$expected" ]; then
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "$name"
    else
        FAIL=$((FAIL + 1))
        FAILED_NAMES="$FAILED_NAMES
    $name"
        printf '  FAIL %s\n' "$name"
        printf '       expected: %s\n' "$(printf '%s' "$expected" | tr '\n' '|')"
        printf '       actual:   %s\n' "$(printf '%s' "$actual" | tr '\n' '|')"
    fi
}

# expected BRANCH U M S ST A B OP -> 8-line fixture (trailing newline stripped by $())
expected() {
    printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s' "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}

mkrepo() {
    repo=$(mktemp -d -t damin-test.XXXXXX)
    git -C "$repo" -c init.defaultBranch=main init -q
    git -C "$repo" commit --allow-empty -q -m init
    printf '%s\n' "$repo"
}

cleanup() {
    for d in "$@"; do
        [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
    done
}

echo "=== damin _damin_git_compute tests ==="
echo

# --- non-git PWD: function returns nothing ---
tmp=$(mktemp -d -t damin-test-notgit.XXXXXX)
got=$(run_compute "$tmp")
expect "non-git pwd: empty output" "$got" ""
cleanup "$tmp"

# --- clean repo, no remote ---
repo=$(mkrepo)
got=$(run_compute "$repo")
expect "clean repo" "$got" "$(expected main 0 0 0 0 0 0 '')"
cleanup "$repo"

# --- 1 untracked (regression: case '?' glob bug counted every line) ---
repo=$(mkrepo)
echo new >"$repo/u"
got=$(run_compute "$repo")
expect "1 untracked file" "$got" "$(expected main 1 0 0 0 0 0 '')"
cleanup "$repo"

# --- 1 modified (tracked, unstaged) ---
repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
got=$(run_compute "$repo")
expect "1 modified" "$got" "$(expected main 0 1 0 0 0 0 '')"
cleanup "$repo"

# --- 1 staged ---
repo=$(mkrepo)
echo new >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "1 staged" "$got" "$(expected main 0 0 1 0 0 0 '')"
cleanup "$repo"

# --- mixed: 1 untracked + 1 modified + 1 staged ---
repo=$(mkrepo)
echo orig >"$repo/m" && git -C "$repo" add m && git -C "$repo" commit -q -m add
echo edit >"$repo/m"
echo new >"$repo/u"
echo staged >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "mixed dirty" "$got" "$(expected main 1 1 1 0 0 0 '')"
cleanup "$repo"

# --- detached HEAD: branch shows 8-char SHA prefix, not "?" ---
repo=$(mkrepo)
sha=$(git -C "$repo" rev-parse HEAD)
prefix=$(printf '%s' "$sha" | cut -c1-8)
git -C "$repo" -c advice.detachedHead=false checkout -q "$sha"
got=$(run_compute "$repo")
expect "detached HEAD shows sha prefix" "$got" "$(expected "$prefix" 0 0 0 0 0 0 '')"
cleanup "$repo"

# --- 1 stash entry ---
repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
git -C "$repo" stash push -q -m wip
got=$(run_compute "$repo")
expect "1 stash entry" "$got" "$(expected main 0 0 0 1 0 0 '')"
cleanup "$repo"

# --- no upstream + remote + 2 unpushed commits (regression: branch.ab fallback) ---
bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" push -q origin main
git -C "$repo" branch --unset-upstream main 2>/dev/null || true
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" commit --allow-empty -q -m c2
got=$(run_compute "$repo")
expect "no upstream + remote + 2 unpushed" "$got" "$(expected main 0 0 0 0 2 0 '')"
cleanup "$repo" "$bare"

# --- no upstream + NO remote + commits: ahead must stay 0 (no false positive) ---
repo=$(mkrepo)
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" commit --allow-empty -q -m c2
got=$(run_compute "$repo")
expect "no remote at all: ahead stays 0" "$got" "$(expected main 0 0 0 0 0 0 '')"
cleanup "$repo"

# --- upstream set + 1 commit ahead ---
bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" push -q --set-upstream origin main
git -C "$repo" commit --allow-empty -q -m c1
got=$(run_compute "$repo")
expect "upstream set, 1 ahead" "$got" "$(expected main 0 0 0 0 1 0 '')"
cleanup "$repo" "$bare"

# --- upstream set + 1 commit behind (rewind local) ---
bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" push -q --set-upstream origin main
git -C "$repo" reset --hard -q HEAD~1
got=$(run_compute "$repo")
expect "upstream set, 1 behind" "$got" "$(expected main 0 0 0 0 0 1 '')"
cleanup "$repo" "$bare"

# --- active rebase: op=rebase ---
repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
# start a rebase that conflicts so it stays mid-flight
git -C "$repo" checkout -q feature
git -C "$repo" rebase main >/dev/null 2>&1 || true
got=$(run_compute "$repo")
# Branch reads as SHA prefix during rebase (git detaches HEAD) — assert op only.
op_line=$(printf '%s' "$got" | sed -n '8p')
expect "active rebase: op is rebase" "$op_line" "rebase"
cleanup "$repo"

# --- active rebase + theme_damin_show_git_op=0: op suppressed (regression) ---
repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
git -C "$repo" checkout -q feature
git -C "$repo" rebase main >/dev/null 2>&1 || true
got=$(run_compute "$repo" "set -g theme_damin_show_git_op 0")
op_line=$(printf '%s' "$got" | sed -n '8p')
expect "rebase + show_git_op=0: op suppressed" "$op_line" ""
cleanup "$repo"

# --- active merge: op=merge ---
repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
git -C "$repo" merge --no-commit --no-ff feature >/dev/null 2>&1 || true
got=$(run_compute "$repo")
op_line=$(printf '%s' "$got" | sed -n '8p')
expect "active merge: op is merge" "$op_line" "merge"
cleanup "$repo"

echo
echo "=== damin _damin_k8s_compute tests ==="
echo

# k8s_compute writes "context\nnamespace\n"; namespace empty when unset.
run_k8s() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        _damin_k8s_compute '$1'
        true
    " 2>/dev/null
}

write_kube() {
    cat >"$1"
}

# --- single context with namespace ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
contexts:
- context:
    cluster: c1
    namespace: production
    user: u1
  name: prod
current-context: prod
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: context + namespace" "$got" "$(printf 'prod\nproduction')"
rm -f "$cfg"

# --- single context, no namespace key ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
contexts:
- context:
    cluster: c1
    user: u1
  name: dev
current-context: dev
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: context, no namespace" "$got" "dev"
rm -f "$cfg"

# --- multiple contexts: picks the matching one ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
contexts:
- context:
    cluster: c1
    namespace: production
    user: u1
  name: prod
- context:
    cluster: c2
    namespace: staging
    user: u2
  name: stage
- context:
    cluster: c3
    user: u3
  name: dev
current-context: stage
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: picks correct entry of many" "$got" "$(printf 'stage\nstaging')"
rm -f "$cfg"

# --- current-context appears before contexts: section ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
current-context: prod
contexts:
- context:
    cluster: c1
    namespace: production
    user: u1
  name: prod
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: current-context before contexts" "$got" "$(printf 'prod\nproduction')"
rm -f "$cfg"

# --- no current-context: returns empty ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
contexts:
- context:
    cluster: c1
    user: u1
  name: dev
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: no current-context = empty output" "$got" ""
rm -f "$cfg"

# --- quoted context name ---
cfg=$(mktemp -t damin-test-kube.XXXXXX)
write_kube "$cfg" <<'EOF'
apiVersion: v1
contexts:
- context:
    cluster: c1
    namespace: "prod"
    user: u1
  name: "prod-us-east"
current-context: "prod-us-east"
kind: Config
EOF
got=$(run_k8s "$cfg")
expect "k8s: quoted values trimmed" "$got" "$(printf 'prod-us-east\nprod')"
rm -f "$cfg"

echo
echo "=== damin _damin_env_render tests ==="
echo

# env render emits colored output; check the inner text only via substring match.
run_env() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        ${1:-}
        _damin_env_render
    " 2>/dev/null
}

expect_contains() {
    name="$1"
    actual="$2"
    needle="$3"
    case "$actual" in
        *"$needle"*)
            PASS=$((PASS + 1))
            printf '  ok   %s\n' "$name"
            ;;
        *)
            FAIL=$((FAIL + 1))
            FAILED_NAMES="$FAILED_NAMES
    $name"
            printf '  FAIL %s\n' "$name"
            printf '       needle:  %s\n' "$needle"
            printf '       in:      %s\n' "$actual"
            ;;
    esac
}

got=$(run_env "set -gx DIRENV_DIR -/home/u/projects/myapp")
expect_contains "env: direnv shows project basename" "$got" "(direnv:myapp)"

got=$(run_env "set -gx IN_NIX_SHELL pure; set -gx name rust-shell")
expect_contains "env: nix devshell shows custom name" "$got" "(nix:rust-shell)"

got=$(run_env "set -gx IN_NIX_SHELL pure; set -gx name nix-shell")
expect_contains "env: nix devshell generic name falls back to nix" "$got" "(nix)"

got=$(run_env "set -gx IN_NIX_SHELL pure; set -gx name rust-shell; set -g theme_damin_show_nix_name 0")
expect_contains "env: show_nix_name=0 forces nix only" "$got" "(nix)"

got=$(run_env "set -gx VIRTUAL_ENV /h/u/.venv/proj; set -gx IN_NIX_SHELL pure; set -gx name ml")
expect_contains "env: venv + nix combined" "$got" "(proj,nix:ml)"

got=$(run_env "")
expect "env: nothing set produces no output" "$got" ""

echo
TOTAL=$((PASS + FAIL))
if [ $FAIL -gt 0 ]; then
    printf '%d/%d failed:%s\n' "$FAIL" "$TOTAL" "$FAILED_NAMES"
    exit 1
fi
printf '%d/%d passed\n' "$PASS" "$TOTAL"
