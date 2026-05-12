#!/bin/sh
# fixture tests for _damin_git_compute (8-line stdout: branch, u, m, s, st, a, b, op).
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

# 8-line fixture builder (trailing newline stripped by $()).
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

tmp=$(mktemp -d -t damin-test-notgit.XXXXXX)
got=$(run_compute "$tmp")
expect "non-git pwd: empty output" "$got" ""
cleanup "$tmp"

repo=$(mkrepo)
got=$(run_compute "$repo")
expect "clean repo" "$got" "$(expected main 0 0 0 0 0 0 '')"
cleanup "$repo"

# regression: glob `?` once matched every line.
repo=$(mkrepo)
echo new >"$repo/u"
got=$(run_compute "$repo")
expect "1 untracked file" "$got" "$(expected main 1 0 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
got=$(run_compute "$repo")
expect "1 modified" "$got" "$(expected main 0 1 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo new >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "1 staged" "$got" "$(expected main 0 0 1 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/m" && git -C "$repo" add m && git -C "$repo" commit -q -m add
echo edit >"$repo/m"
echo new >"$repo/u"
echo staged >"$repo/s" && git -C "$repo" add s
got=$(run_compute "$repo")
expect "mixed dirty" "$got" "$(expected main 1 1 1 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
sha=$(git -C "$repo" rev-parse HEAD)
prefix=$(printf '%s' "$sha" | cut -c1-8)
git -C "$repo" -c advice.detachedHead=false checkout -q "$sha"
got=$(run_compute "$repo")
expect "detached HEAD shows sha prefix" "$got" "$(expected "$prefix" 0 0 0 0 0 0 '')"
cleanup "$repo"

repo=$(mkrepo)
echo orig >"$repo/f" && git -C "$repo" add f && git -C "$repo" commit -q -m add
echo edit >"$repo/f"
git -C "$repo" stash push -q -m wip
got=$(run_compute "$repo")
expect "1 stash entry" "$got" "$(expected main 0 0 0 1 0 0 '')"
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
expect "no upstream + remote + 2 unpushed" "$got" "$(expected main 0 0 0 0 2 0 '')"
cleanup "$repo" "$bare"

# no remote at all: ahead must stay 0 (no false positive).
repo=$(mkrepo)
git -C "$repo" commit --allow-empty -q -m c1
git -C "$repo" commit --allow-empty -q -m c2
got=$(run_compute "$repo")
expect "no remote at all: ahead stays 0" "$got" "$(expected main 0 0 0 0 0 0 '')"
cleanup "$repo"

bare=$(mktemp -d -t damin-test-bare.XXXXXX)
git -c init.defaultBranch=main init --bare -q "$bare"
repo=$(mkrepo)
git -C "$repo" remote add origin "$bare"
git -C "$repo" push -q --set-upstream origin main
git -C "$repo" commit --allow-empty -q -m c1
got=$(run_compute "$repo")
expect "upstream set, 1 ahead" "$got" "$(expected main 0 0 0 0 1 0 '')"
cleanup "$repo" "$bare"

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
op_line=$(printf '%s' "$got" | sed -n '8p')
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
op_line=$(printf '%s' "$got" | sed -n '8p')
expect "rebase + show_git_op=0: op suppressed" "$op_line" ""
cleanup "$repo"

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
expect "exit label: off → empty" "$got" ""

got=$(run_exit_label 0 127)
expect "exit label: 0 → empty (legacy)" "$got" ""

got=$(run_exit_label hidden 130)
expect "exit label: hidden → empty" "$got" ""

got=$(run_exit_label 1 127)
expect "exit label: 1 → 127 (legacy)" "$got" "127"

got=$(run_exit_label number 130)
expect "exit label: number → 130" "$got" "130"

got=$(run_exit_label name 130)
expect "exit label: name → SIGINT" "$got" "SIGINT"

got=$(run_exit_label name 127)
expect "exit label: name → not-found" "$got" "not-found"

got=$(run_exit_label both 130)
expect "exit label: both → 130 SIGINT" "$got" "130 SIGINT"

got=$(run_exit_label both 42)
expect "exit label: both → 42 (unmapped stays raw)" "$got" "42"

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
expect "palette: mocha → text=cdd6f4" "$got" "cdd6f4"

got=$(run_dumb "
    set -g theme_damin_palette frappe
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: frappe → text=c6d0f5" "$got" "c6d0f5"

got=$(run_dumb "
    set -g theme_damin_palette macchiato
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: macchiato → text=cad3f5" "$got" "cad3f5"

got=$(run_dumb "
    set -g theme_damin_palette latte
    source '$THEME/conf.d/damin.fish'
    echo \$fish_color_normal
    true
")
expect "palette: latte → text=4c4f69" "$got" "4c4f69"

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
