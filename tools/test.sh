#!/bin/sh
# fixture tests for _damin_git_compute (9-line stdout: branch, u, m, s, st, a, b, c, op).
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

# trailing `true` keeps fish exit 0 on non-git pwd so `set -e` doesn't fire on $().
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

# 10-line fixture builder (trailing newline stripped by $()).
# fields: branch, untracked, modified, staged, stashed, ahead, behind, conflict, op, stash_ts.
expected() {
    printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s' "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10:-0}"
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

tmp=$(mktemp -d -t damin-test-notgit.XXXXXX)
got=$(run_compute "$tmp")
expect "non-git pwd: empty output" "$got" ""
cleanup "$tmp"

repo=$(mkrepo)
got=$(run_compute "$repo")
expect "clean repo" "$got" "$(expected main 0 0 0 0 0 0 0 '')"
cleanup "$repo"

# regression: glob `?` once matched every line.
repo=$(mkrepo)
echo new >"$repo/u"
got=$(run_compute "$repo")
expect "1 untracked file" "$got" "$(expected main 1 0 0 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
got=$(run_compute "$repo")
expect "1 modified" "$got" "$(expected main 0 1 0 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo new >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "1 staged" "$got" "$(expected main 0 0 1 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/m" && git -C "$repo" add m && git -C "$repo" commit -q -m add
echo edit >"$repo/m"
echo new >"$repo/u"
echo staged >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "mixed dirty" "$got" "$(expected main 1 1 1 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
sha=$(git -C "$repo" rev-parse HEAD)
prefix=$(printf '%s' "$sha" | cut -c1-8)
git -C "$repo" -c advice.detachedHead=false checkout -q "$sha"
got=$(run_compute "$repo")
expect "detached HEAD shows sha prefix" "$got" "$(expected "$prefix" 0 0 0 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
git -C "$repo" stash push -q -m wip
got=$(run_compute "$repo")
# strip dynamic stash_ts (line 10) before strict equality; assert it's a positive int separately.
head_9=$(printf '%s' "$got" | sed -n '1,9p')
ts_line=$(printf '%s' "$got" | sed -n '10p')
want_9=$(printf 'main\n0\n0\n0\n1\n0\n0\n0\n')
expect "1 stash entry: first 9 fields" "$head_9" "$want_9"
case "$ts_line" in
    [1-9]*)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "1 stash entry: stash_ts is a positive int"
        ;;
    *)
        FAIL=$((FAIL + 1))
        printf '  FAIL %s (got: %s)\n' "1 stash entry: stash_ts is a positive int" "$ts_line"
        ;;
esac
cleanup "$repo"

# regression: branch.ab fallback when upstream is unset.
bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" push -q origin main
git -C "$repo" branch --unset-upstream main 2>/dev/null || true
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" commit --allow-empty -q -m c2
got=$(run_compute "$repo")
expect "no upstream + remote + 2 unpushed" "$got" "$(expected main 0 0 0 0 2 0 0 '')"
cleanup "$repo" "$bare"

# no remote at all: ahead must stay 0 (no false positive).
repo=$(mkrepo)
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" commit --allow-empty -q -m c2
got=$(run_compute "$repo")
expect "no remote at all: ahead stays 0" "$got" "$(expected main 0 0 0 0 0 0 0 '')"
cleanup "$repo"

bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" push -q --set-upstream origin main
git -C "$repo" commit --allow-empty -q -m c1
got=$(run_compute "$repo")
expect "upstream set, 1 ahead" "$got" "$(expected main 0 0 0 0 1 0 0 '')"
cleanup "$repo" "$bare"

bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" push -q --set-upstream origin main
git -C "$repo" reset --hard -q HEAD~1
got=$(run_compute "$repo")
expect "upstream set, 1 behind" "$got" "$(expected main 0 0 0 0 0 1 0 '')"
cleanup "$repo" "$bare"

repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
# rebase that conflicts so it stays mid-flight.
git -C "$repo" checkout -q feature
git -C "$repo" rebase main >/dev/null 2>&1 || true
got=$(run_compute "$repo")
# branch reads as sha prefix during rebase (git detaches HEAD) — assert op only.
op_line=$(printf '%s' "$got" | sed -n '9p')
expect "active rebase: op is rebase" "$op_line" "rebase"
cleanup "$repo"

# regression: show_git_op=0 must suppress op even mid-flight.
repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
git -C "$repo" checkout -q feature
git -C "$repo" rebase main >/dev/null 2>&1 || true
got=$(run_compute "$repo" "set -g theme_damin_show_git_op 0")
op_line=$(printf '%s' "$got" | sed -n '9p')
expect "rebase + show_git_op=0: op suppressed" "$op_line" ""
cleanup "$repo"

repo=$(mkrepo)
git -C "$repo" checkout -q -b feature
echo a >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m feat
git -C "$repo" checkout -q main
echo b >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m base
git -C "$repo" merge --no-commit --no-ff feature >/dev/null 2>&1 || true
got=$(run_compute "$repo")
op_line=$(printf '%s' "$got" | sed -n '9p')
expect "active merge: op is merge" "$op_line" "merge"
# conflict count sits at line 8 (UU file from the failed merge).
conflict_line=$(printf '%s' "$got" | sed -n '8p')
expect "active merge: 1 conflict (UU)" "$conflict_line" "1"
cleanup "$repo"

# worktree detection: gitdir points to .git/worktrees/<name>; basename is the wt name.
repo=$(mkrepo)
wtroot=$(mktemp -d -t damin-test-wt.XXXXXX)
git -C "$repo" worktree add -q -b feature-x "$wtroot/feature-x" >/dev/null 2>&1
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    cd '$wtroot/feature-x'
    _damin_detect_vcs >/dev/null
    echo \$_damin_vcs_worktree
    true
" 2>/dev/null)
expect "worktree: gitdir basename surfaced" "$got" "feature-x"
cleanup "$repo" "$wtroot"

# vcs_ignore_paths: glob match short-circuits detection.
repo=$(mkrepo)
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_vcs_ignore_paths '$repo/*' '$repo'
    cd '$repo'
    set -l v (_damin_detect_vcs)
    echo \"[\$v]\"
    true
" 2>/dev/null)
expect "vcs_ignore_paths: glob match -> no detection" "$got" "[]"
cleanup "$repo"

# hg detection: opt-in via show_hg, .hg/ found.
hgrepo=$(mktemp -d -t damin-test-hg.XXXXXX)
mkdir -p "$hgrepo/.hg"
printf 'feature-branch\n' >"$hgrepo/.hg/branch"
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_hg 1
    cd '$hgrepo'
    _damin_detect_vcs
    true
" 2>/dev/null)
expect "hg: detected when show_hg=1 and .hg/ exists" "$got" "hg"
cleanup "$hgrepo"

hgrepo=$(mktemp -d -t damin-test-hg.XXXXXX)
mkdir -p "$hgrepo/.hg"
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_hg 0
    cd '$hgrepo'
    set -l v (_damin_detect_vcs)
    echo \"[\$v]\"
    true
" 2>/dev/null)
expect "hg: ignored when show_hg=0" "$got" "[]"
cleanup "$hgrepo"

# fossil detection: opt-in via show_fossil, .fslckout found.
fosrepo=$(mktemp -d -t damin-test-fos.XXXXXX)
touch "$fosrepo/.fslckout"
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_fossil 1
    cd '$fosrepo'
    _damin_detect_vcs
    true
" 2>/dev/null)
expect "fossil: detected when show_fossil=1 and .fslckout exists" "$got" "fossil"
cleanup "$fosrepo"

# branch_max_len: truncate to N chars with ellipsis (rendered via render_data).
repo=$(mkrepo)
git -C "$repo" checkout -q -b release/very-long-feature-branch-name-2026
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_branch_max_len 10
    cd '$repo'
    _damin_vcs_render
    true
" 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')
case "$got" in
    *"release/v…"*)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "branch_max_len=10: truncates with …"
        ;;
    *)
        FAIL=$((FAIL + 1))
        printf '  FAIL %s\n       got: %s\n' "branch_max_len: truncates with …" "$got"
        ;;
esac
cleanup "$repo"

echo
echo "=== damin _damin_k8s_compute tests ==="
echo

# _damin_k8s_compute writes "context\nnamespace\n"; namespace empty when unset.
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
echo "=== damin cloud context tests ==="
echo

run_aws_region() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        _damin_aws_region_for '$1' '$2'
        true
    " 2>/dev/null
}

cfg=$(mktemp -t damin-test-aws.XXXXXX)
cat >"$cfg" <<'EOF'
[default]
region = us-east-1
output = json

[profile prod]
region = eu-west-2
EOF
got=$(run_aws_region default "$cfg")
expect "aws: default profile region" "$got" "us-east-1"

got=$(run_aws_region prod "$cfg")
expect "aws: named profile region" "$got" "eu-west-2"

got=$(run_aws_region nonexistent "$cfg")
expect "aws: unknown profile = empty" "$got" ""
rm -f "$cfg"

got=$(run_aws_region default /tmp/damin-aws-missing-$$)
expect "aws: missing file = empty" "$got" ""

run_azure() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        _damin_azure_compute '$1'
        true
    " 2>/dev/null
}

azf=$(mktemp -t damin-test-az.XXXXXX)
cat >"$azf" <<'EOF'
{
  "subscriptions": [
    {
      "id": "11111111-2222-3333-4444-555555555555",
      "name": "Prod",
      "isDefault": true,
      "tenantId": "t1"
    },
    {
      "id": "66666666-7777-8888-9999-000000000000",
      "name": "Dev",
      "isDefault": false,
      "tenantId": "t1"
    }
  ]
}
EOF
got=$(run_azure "$azf")
expect "azure: default subscription extracted" "$got" "Prod"
rm -f "$azf"

azf=$(mktemp -t damin-test-az.XXXXXX)
cat >"$azf" <<'EOF'
{
  "subscriptions": [
    {"id":"x","name":"Stage","isDefault":false},
    {"id":"y","name":"Production-US","isDefault":true}
  ]
}
EOF
got=$(run_azure "$azf")
expect "azure: second isDefault entry" "$got" "Production-US"
rm -f "$azf"

azf=$(mktemp -t damin-test-az.XXXXXX)
cat >"$azf" <<'EOF'
{"subscriptions":[{"name":"A","isDefault":false}]}
EOF
got=$(run_azure "$azf")
expect "azure: no default = empty" "$got" ""
rm -f "$azf"

got=$(run_azure /tmp/damin-az-missing-$$)
expect "azure: missing file = empty" "$got" ""

gcp_root=$(mktemp -d -t damin-test-gcp.XXXXXX)
mkdir -p "$gcp_root/configurations"
echo "work" >"$gcp_root/active_config"
cat >"$gcp_root/configurations/config_work" <<'EOF'
[core]
account = me@example.com
project = my-cool-project
[compute]
region = us-central1
EOF
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -gx CLOUDSDK_CONFIG '$gcp_root'
    set -g theme_damin_show_gcp 1
    _damin_gcp_render
    true
" 2>/dev/null)
case "$got" in
    *"gcp:my-cool-project"*)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "gcp: active_config + project resolved"
        ;;
    *)
        FAIL=$((FAIL + 1))
        FAILED_NAMES="$FAILED_NAMES
    gcp: active_config + project resolved"
        printf '  FAIL %s\n' "gcp: active_config + project resolved"
        printf '       in: %s\n' "$got"
        ;;
esac
rm -rf "$gcp_root"

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -gx CLOUDSDK_CORE_PROJECT 'env-project'
    set -gx CLOUDSDK_CONFIG '/tmp/damin-gcp-missing-$$'
    set -g theme_damin_show_gcp 1
    _damin_gcp_render
    true
" 2>/dev/null)
case "$got" in
    *"gcp:env-project"*)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "gcp: CLOUDSDK_CORE_PROJECT short-circuit"
        ;;
    *)
        FAIL=$((FAIL + 1))
        FAILED_NAMES="$FAILED_NAMES
    gcp: CLOUDSDK_CORE_PROJECT short-circuit"
        printf '  FAIL %s\n' "gcp: CLOUDSDK_CORE_PROJECT short-circuit"
        printf '       in: %s\n' "$got"
        ;;
esac

echo
echo "=== damin OSC 7 / OSC 133 tests ==="
echo

expected_133a=$(printf '\033]133;A\007')
got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_osc_integration 1
    _damin_osc133_a
    true
" 2>/dev/null)
expect "osc: 133;A emitted" "$got" "$expected_133a"

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_osc_integration 0
    _damin_osc133_a
    true
" 2>/dev/null)
expect "osc: integration=0 emits nothing" "$got" ""

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    _damin_osc_encode_path '/tmp/has space/sub'
    true
" 2>/dev/null)
expect "osc: path encoding escapes space" "$got" "/tmp/has%20space/sub"

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    _damin_osc_encode_path '/usr/local/bin'
    true
" 2>/dev/null)
expect "osc: path encoding preserves slashes" "$got" "/usr/local/bin"

echo
echo "=== damin status name + dumb detect tests ==="
echo

run_status() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        _damin_status_name $1
        true
    " 2>/dev/null
}

got=$(run_status 126)
expect "status: 126 = noexec" "$got" "noexec"

got=$(run_status 127)
expect "status: 127 = not-found" "$got" "not-found"

got=$(run_status 130)
expect "status: 130 = SIGINT" "$got" "SIGINT"

got=$(run_status 137)
expect "status: 137 = SIGKILL" "$got" "SIGKILL"

got=$(run_status 143)
expect "status: 143 = SIGTERM" "$got" "SIGTERM"

got=$(run_status 129)
expect "status: 129 = SIGHUP" "$got" "SIGHUP"

got=$(run_status 131)
expect "status: 131 = SIGQUIT" "$got" "SIGQUIT"

got=$(run_status 134)
expect "status: 134 = SIGABRT" "$got" "SIGABRT"

got=$(run_status 139)
expect "status: 139 = SIGSEGV" "$got" "SIGSEGV"

got=$(run_status 141)
expect "status: 141 = SIGPIPE" "$got" "SIGPIPE"

got=$(run_status 1)
expect "status: 1 stays raw (no mapping)" "$got" "1"

got=$(run_status 42)
expect "status: 42 stays raw (no mapping)" "$got" "42"

got=$(run_status 200)
expect "status: 200 stays raw (no mapping)" "$got" "200"

run_exit_label() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        set -g theme_damin_show_exit_code $1
        _damin_exit_label $2
        true
    " 2>/dev/null
}

got=$(run_exit_label off 130)
expect "exit label: off -> empty" "$got" ""

got=$(run_exit_label 0 127)
expect "exit label: 0 -> empty (legacy)" "$got" ""

got=$(run_exit_label hidden 130)
expect "exit label: hidden -> empty" "$got" ""

got=$(run_exit_label 1 127)
expect "exit label: 1 -> 127 (legacy)" "$got" "127"

got=$(run_exit_label number 130)
expect "exit label: number -> 130" "$got" "130"

got=$(run_exit_label name 130)
expect "exit label: name -> SIGINT" "$got" "SIGINT"

got=$(run_exit_label name 127)
expect "exit label: name -> not-found" "$got" "not-found"

got=$(run_exit_label both 130)
expect "exit label: both -> 130 SIGINT" "$got" "130 SIGINT"

got=$(run_exit_label both 42)
expect "exit label: both -> 42 (unmapped stays raw)" "$got" "42"

# temp HOME isolates the test fish from user-set universals (omf-installed damin etc.).
run_dumb() {
    tmphome=$(mktemp -d -t damin-test-home.XXXXXX)
    HOME="$tmphome" XDG_CONFIG_HOME="$tmphome/.config" XDG_DATA_HOME="$tmphome/.local/share" \
        fish --no-config -c "$1" 2>/dev/null
    rm -rf "$tmphome"
}

got=$(run_dumb "
    set -gx TERM dumb
    source '$THEME/conf.d/damin.fish'
    echo \$theme_damin_ascii \$theme_damin_transient \$theme_damin_osc_integration \$theme_damin_apply_colors
    true
")
expect "dumb: TERM=dumb auto-minimal" "$got" "1 0 0 0"

got=$(run_dumb "
    set -gx INSIDE_EMACS 'tramp,29.1'
    source '$THEME/conf.d/damin.fish'
    echo \$theme_damin_ascii \$theme_damin_transient \$theme_damin_osc_integration \$theme_damin_apply_colors
    true
")
expect "dumb: INSIDE_EMACS auto-minimal" "$got" "1 0 0 0"

got=$(run_dumb "
    set -gx TERM dumb
    set -g theme_damin_ascii 0
    set -g theme_damin_transient 1
    set -g theme_damin_osc_integration 1
    set -g theme_damin_apply_colors 1
    source '$THEME/conf.d/damin.fish'
    echo \$theme_damin_ascii \$theme_damin_transient \$theme_damin_osc_integration \$theme_damin_apply_colors
    true
")
expect "dumb: explicit user values override auto-minimal" "$got" "0 1 1 1"

got=$(run_dumb "
    set -g theme_damin_palette mocha
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: mocha -> text=cdd6f4" "$got" "cdd6f4"

got=$(run_dumb "
    set -g theme_damin_palette frappe
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: frappe -> text=c6d0f5" "$got" "c6d0f5"

got=$(run_dumb "
    set -g theme_damin_palette macchiato
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: macchiato -> text=cad3f5" "$got" "cad3f5"

got=$(run_dumb "
    set -g theme_damin_palette latte
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: latte -> text=4c4f69" "$got" "4c4f69"

got=$(run_dumb "
    set -g theme_damin_palette solarized
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: solarized -> text=839496" "$got" "839496"

got=$(run_dumb "
    set -g theme_damin_palette solarized-light
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: solarized-light -> text=657b83" "$got" "657b83"

got=$(run_dumb "
    set -g theme_damin_palette solarized
    source '$THEME/conf.d/damin.fish'
    echo \$theme_damin_accent_primary \$theme_damin_accent_secondary
    true
")
expect "palette: solarized accents -> 268bd2 / d33682" "$got" "268bd2 d33682"

got=$(run_dumb "
    set -g theme_damin_palette base16
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal \$theme_damin_accent_primary
    true
")
expect "palette: base16 -> text=d8d8d8 accent=7cafc2" "$got" "d8d8d8 7cafc2"

got=$(run_dumb "
    set -g theme_damin_palette zenburn
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal \$theme_damin_accent_primary
    true
")
expect "palette: zenburn -> text=dcdccc accent=8cd0d3" "$got" "dcdccc 8cd0d3"

got=$(run_dumb "
    set -g theme_damin_palette gruvbox-light
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal \$theme_damin_accent_primary
    true
")
expect "palette: gruvbox-light -> text=3c3836 accent=458588" "$got" "3c3836 458588"

got=$(run_dumb "
    set -g theme_damin_palette terminal-dark
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal \$theme_damin_accent_primary
    true
")
expect "palette: terminal-dark -> named colors" "$got" "white blue"

got=$(run_dumb "
    set -g theme_damin_palette high-contrast
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal \$theme_damin_accent_primary
    true
")
expect "palette: high-contrast -> text=ffffff accent=87ceeb" "$got" "ffffff 87ceeb"

echo
echo "=== damin _damin_relative_time tests ==="
echo

run_rel() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        _damin_relative_time $1
        true
    " 2>/dev/null
}

now=$(date +%s)
got=$(run_rel "$((now - 30))")
expect "rel: 30s -> now" "$got" "now"

got=$(run_rel "$((now - 600))")
expect "rel: 10min -> 10m" "$got" "10m"

got=$(run_rel "$((now - 7200))")
expect "rel: 2h -> 2h" "$got" "2h"

got=$(run_rel "$((now - 172800))")
expect "rel: 2d -> 2d" "$got" "2d"

got=$(run_rel "")
expect "rel: empty -> empty" "$got" ""

got=$(run_rel "abc")
expect "rel: non-numeric -> empty" "$got" ""

echo
echo "=== damin issue auto-link tests ==="
echo

run_link() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        set -g theme_damin_issue_url_template '$1'
        cd '$2'
        _damin_vcs_render
        true
    " 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g'
}

repo=$(mkrepo)
git -C "$repo" checkout -q -b JIRA-123/feature
got=$(run_link 'https://jira.example.com/{key}' "$repo")
case "$got" in
    *"https://jira.example.com/JIRA-123"*)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "issue link: JIRA-123 surfaced via OSC 8"
        ;;
    *)
        FAIL=$((FAIL + 1))
        printf '  FAIL %s\n       got: %s\n' "issue link: JIRA-123 surfaced via OSC 8" "$got"
        ;;
esac
cleanup "$repo"

repo=$(mkrepo)
git -C "$repo" checkout -q -b plain-branch-no-key
got=$(run_link 'https://jira.example.com/{key}' "$repo")
case "$got" in
    *"https://jira"*)
        FAIL=$((FAIL + 1))
        printf '  FAIL %s\n       (got URL on a branch with no key)\n' "issue link: non-matching branch = no link"
        ;;
    *)
        PASS=$((PASS + 1))
        printf '  ok   %s\n' "issue link: non-matching branch = no link"
        ;;
esac
cleanup "$repo"

echo
echo "=== damin default_user tests ==="
echo

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_user always
    set -g theme_damin_show_host no
    set -gx USER alice
    _damin_context_render
    true
" 2>/dev/null | tr -d '\016\017' | sed 's/\x1b\[[0-9;]*m//g;s/^ *//;s/ *$//')
expect "default_user unset: user always shown" "$got" "alice"

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_user always
    set -g theme_damin_show_host no
    set -g theme_damin_default_user alice
    set -gx USER alice
    _damin_context_render
    true
" 2>/dev/null | tr -d '\016\017' | sed 's/\x1b\[[0-9;]*m//g;s/^ *//;s/ *$//')
expect "default_user match: user suppressed" "$got" ""

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_show_user always
    set -g theme_damin_show_host no
    set -g theme_damin_default_user alice
    set -gx USER bob
    _damin_context_render
    true
" 2>/dev/null | tr -d '\016\017' | sed 's/\x1b\[[0-9;]*m//g;s/^ *//;s/ *$//')
expect "default_user differs: user still shown" "$got" "bob"

echo
echo "=== damin damin_colors hook ==="
echo

got=$(fish -c "
    function damin_colors
        set -g _damin_c_branch BRANCH_OVERRIDE
    end
    source '$THEME/conf.d/damin.fish'
    echo \$_damin_c_branch
    true
" 2>/dev/null)
expect "damin_colors hook overrides _damin_c_branch" "$got" "BRANCH_OVERRIDE"

echo
echo "=== damin lang_global tests ==="
echo

run_lang_global() {
    fish -c "
        source '$THEME/conf.d/damin.fish'
        ${1:-}
        _damin_lang_global
        true
    " 2>/dev/null
}

got=$(run_lang_global "set -gx RBENV_VERSION 3.2.1")
expect "lang_global: rbenv 3.2.1" "$got" "rb:3.2.1"

got=$(run_lang_global "set -gx RBENV_VERSION system")
expect "lang_global: rbenv system -> empty" "$got" ""

got=$(run_lang_global "set -gx PYENV_VERSION 3.11.5")
expect "lang_global: pyenv 3.11.5" "$got" "py:3.11.5"

got=$(run_lang_global "set -gx NVM_BIN /home/u/.nvm/versions/node/v20.10.0/bin")
expect "lang_global: nvm v20.10.0 stripped" "$got" "node:20.10.0"

got=$(run_lang_global "set -gx rvm_ruby_string ruby-3.2.0")
expect "lang_global: rvm ruby-3.2.0 stripped" "$got" "rb:3.2.0"

got=$(run_lang_global "")
expect "lang_global: nothing set -> empty" "$got" ""

echo
echo "=== damin custom segment hooks ==="
echo

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    function damin_segment_hello
        echo -n ' [HELLO]'
    end
    function damin_segment_world
        echo -n ' [WORLD]'
    end
    set -g theme_damin_extra_left hello world
    _damin_extra_segments_render left
    true
" 2>/dev/null)
expect "hooks: left segments fire in order" "$got" " [HELLO] [WORLD]"

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    set -g theme_damin_extra_right missing
    _damin_extra_segments_render right
    true
" 2>/dev/null)
expect "hooks: missing segment function = silent skip" "$got" ""

got=$(fish -c "
    source '$THEME/conf.d/damin.fish'
    _damin_extra_segments_render left
    true
" 2>/dev/null)
expect "hooks: unset extra_left -> no output" "$got" ""

echo
echo "=== damin async repaint kickoff ==="
echo

tmphome=$(mktemp -d -t damin-test-home.XXXXXX)
tmprepo=$(mkrepo)
HOME="$tmphome" XDG_CONFIG_HOME="$tmphome/.config" \
    fish --no-config -c "
        set -g theme_damin_async_repaint 1
        source '$THEME/conf.d/damin.fish' 2>/dev/null
        cd '$tmprepo'
        _damin_git_render >/dev/null
        # bg subshell needs time to fork, run git, and write the cache file.
        for _ in (seq 30)
            test (count \$_damin_cache_dir/*-git 2>/dev/null) -gt 0; and break
            sleep 0.1
        end
        test (count \$_damin_cache_dir/*-git 2>/dev/null) -gt 0; and echo cached; or echo missing
        true
    " 2>/dev/null >"$tmphome/out"
result=$(cat "$tmphome/out")
expect "async repaint: bg subshell writes cache" "$result" "cached"
rm -rf "$tmphome" "$tmprepo"

echo
TOTAL=$((PASS + FAIL))
if [ $FAIL -gt 0 ]; then
    printf '%d/%d failed:%s\n' "$FAIL" "$TOTAL" "$FAILED_NAMES"
    exit 1
fi
printf '%d/%d passed\n' "$PASS" "$TOTAL"
