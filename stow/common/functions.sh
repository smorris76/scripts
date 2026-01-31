#!/usr/bin/env bash
log()  { printf '%s\n' "[-] $*"; }
ok()   { printf '%s\n' "[✓] $*"; }
warn() { printf '%s\n' "[!] $*" >&2; }
die()  { printf '%s\n' "[✗] $*" >&2; exit 1; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }