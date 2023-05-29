#!/usr/bin/env bash
set -eu -o pipefail

check_tag() {
    local expected=$1
    local actual=$2
    local filename=$3

    if [[ $actual != $expected ]]; then
        echo >&2 "Error: the current tag does not match the version in $filename: found $actual, expected $expected"
        return 1
    fi
}

read_version() {
    grep '^version = ' | cut -d \" -f 2
}

ret=0
current_tag=${GITHUB_REF#'refs/tags/v'}

file_tag="$(cat Cargo.toml | read_version)"
check_tag $current_tag $file_tag Cargo.toml || ret=1

lock_tag=$(grep -A 1 '^name = "meilisearch-auth"' Cargo.lock | read_version)
check_tag $current_tag $lock_tag Cargo.lock || ret=1

if (( ret == 0 )); then
    echo 'OK'
fi
exit $ret
