#!/usr/bin/env bash
# hooks/prism-version-check.sh
# BC-6.01.001 PC#8 — prism minimum version gate.
# Minimum required version: 1.0.0-rc.1
#
# Exits 0  if installed prism --version >= 1.0.0-rc.1
# Exits 1  if installed prism --version < 1.0.0-rc.1
# Exits 2  if prism is not found or version cannot be parsed

set -euo pipefail

# Self-enforce ASCII-ordinal collation so [[ > ]] / [[ < ]] in semver_ge() are
# locale-neutral regardless of the caller's environment (e.g. en_US.UTF-8).
# Without this, UTF-8 locales sort uppercase after lowercase ('R' > 'r'),
# causing semver_ge("1.0.0-RC.1", "1.0.0-rc.1") to return 0 (WRONG-ALLOW).
# The production caller (SKILL.md:46) does not set LC_ALL, so we must do it here.
export LC_ALL=C

MIN_VERSION="1.0.0-rc.1"

if ! command -v prism > /dev/null 2>&1; then
    printf 'ERROR: prism binary not found in PATH\n' >&2
    exit 2
fi

version_output="$(prism --version 2>&1)" || true

# Extract semver string: e.g. "prism 1.2.3-rc.4" -> "1.2.3-rc.4"
# Use || true so a grep-no-match (exit 1) under set -euo pipefail does not abort
# the script before the explicit exit 2 guard below can fire.
version="$(printf '%s' "$version_output" \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' \
    | head -1)" || true

if [[ -z "$version" ]]; then
    printf 'ERROR: could not parse prism version from output: %s\n' \
        "$version_output" >&2
    exit 2
fi

# ---------------------------------------------------------------------------
# semver_ge v1 v2 — returns 0 (true) if v1 >= v2, 1 (false) otherwise.
# Handles pre-release tags per semver: 1.0.0 > 1.0.0-rc.1 (release > pre).
# ---------------------------------------------------------------------------
semver_ge() {
    local v1="$1" v2="$2"

    # Split off pre-release suffix (text after first '-')
    local v1_main v1_pre v2_main v2_pre
    if [[ "$v1" == *-* ]]; then
        v1_main="${v1%%-*}"
        v1_pre="${v1#*-}"
    else
        v1_main="$v1"
        v1_pre=""
    fi
    if [[ "$v2" == *-* ]]; then
        v2_main="${v2%%-*}"
        v2_pre="${v2#*-}"
    else
        v2_main="$v2"
        v2_pre=""
    fi

    local maj1 min1 pat1 maj2 min2 pat2
    IFS='.' read -r maj1 min1 pat1 <<< "$v1_main"
    IFS='.' read -r maj2 min2 pat2 <<< "$v2_main"

    # Compare major (10# prefix: force base-10, avoids octal parse of leading-zero segments
    # such as "08" or "09" — mirrors the 10# fix already applied to pre-release fields).
    if (( 10#$maj1 > 10#$maj2 )); then return 0; fi
    if (( 10#$maj1 < 10#$maj2 )); then return 1; fi

    # Compare minor
    if (( 10#$min1 > 10#$min2 )); then return 0; fi
    if (( 10#$min1 < 10#$min2 )); then return 1; fi

    # Compare patch
    if (( 10#$pat1 > 10#$pat2 )); then return 0; fi
    if (( 10#$pat1 < 10#$pat2 )); then return 1; fi

    # Same major.minor.patch — compare pre-release.
    # Semver: no pre-release > any pre-release  (1.0.0 > 1.0.0-rc.1)
    if [[ -z "$v1_pre" && -n "$v2_pre" ]]; then return 0; fi
    if [[ -n "$v1_pre" && -z "$v2_pre" ]]; then return 1; fi
    if [[ -z "$v1_pre" && -z "$v2_pre" ]]; then return 0; fi

    # Both have pre-release — compare per semver §11: split on dots, compare each
    # field: purely numeric identifiers compared numerically (so rc.2 < rc.10);
    # alphanumeric identifiers compared lexically (ASCII, LC_ALL=C); numeric
    # identifiers have lower precedence than alphanumeric; a larger set of fields
    # is greater than a smaller set when all preceding fields are equal.
    local -a _p1_arr _p2_arr
    IFS='.' read -r -a _p1_arr <<< "$v1_pre"
    IFS='.' read -r -a _p2_arr <<< "$v2_pre"
    local _p1_len=${#_p1_arr[@]} _p2_len=${#_p2_arr[@]}
    local _max_len
    (( _p1_len > _p2_len )) && _max_len=$_p1_len || _max_len=$_p2_len
    local _i _s1 _s2
    for (( _i = 0; _i < _max_len; _i++ )); do
        _s1="${_p1_arr[$_i]:-}"
        _s2="${_p2_arr[$_i]:-}"
        # One side exhausted: longer (more fields) is greater
        if [[ -z "$_s1" ]]; then return 1; fi
        if [[ -z "$_s2" ]]; then return 0; fi
        # Both purely numeric → numeric comparison (force base-10 to avoid
        # treating leading-zero identifiers such as rc.08 as octal).
        if [[ "$_s1" =~ ^[0-9]+$ ]] && [[ "$_s2" =~ ^[0-9]+$ ]]; then
            if (( 10#$_s1 > 10#$_s2 )); then return 0; fi
            if (( 10#$_s1 < 10#$_s2 )); then return 1; fi
        else
            # numeric < alphanumeric (semver §11.4.1)
            if [[ "$_s1" =~ ^[0-9]+$ ]]; then return 1; fi
            if [[ "$_s2" =~ ^[0-9]+$ ]]; then return 0; fi
            # Both alphanumeric: ASCII-ordinal string compare (caller sets LC_ALL=C)
            if [[ "$_s1" > "$_s2" ]]; then return 0; fi
            if [[ "$_s1" < "$_s2" ]]; then return 1; fi
        fi
    done
    return 0  # equal pre-release — v1 >= v2
}

if semver_ge "$version" "$MIN_VERSION"; then
    printf 'prism %s meets minimum requirement %s\n' "$version" "$MIN_VERSION"
    exit 0
else
    printf 'ERROR: prism %s does not meet minimum requirement %s\n' \
        "$version" "$MIN_VERSION" >&2
    exit 1
fi
