#!/usr/bin/env bash

set -euo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ENTRYPOINT="${ROOT}/bin/outpost-entrypoint"
readonly TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

readonly SKEL="${TMP}/skel"
readonly EMPTY_HOME="${TMP}/empty-home"
readonly EXISTING_HOME="${TMP}/existing-home"

mkdir -p "${SKEL}/.config" "${EMPTY_HOME}" "${EXISTING_HOME}"
: > "${SKEL}/.bashrc"
cp "${ROOT}/default_bash_logout.sh" "${SKEL}/.bash_logout"
printf 'keep me\\n' > "${EXISTING_HOME}/sentinel"

HOME="${EMPTY_HOME}" OUTPOST_SKEL_DIR="${SKEL}" "${ENTRYPOINT}" /bin/true

[[ -f "${EMPTY_HOME}/.bashrc" ]]
[[ ! -s "${EMPTY_HOME}/.bashrc" ]]
[[ -f "${EMPTY_HOME}/.bash_logout" ]]
[[ -d "${EMPTY_HOME}/.config" ]]
[[ -z "$(find "${EMPTY_HOME}/.config" -mindepth 1 -print -quit)" ]]

HOME="${EXISTING_HOME}" OUTPOST_SKEL_DIR="${SKEL}" "${ENTRYPOINT}" /bin/true

[[ -f "${EXISTING_HOME}/sentinel" ]]
[[ ! -e "${EXISTING_HOME}/.bashrc" ]]
[[ ! -e "${EXISTING_HOME}/.bash_logout" ]]
[[ ! -e "${EXISTING_HOME}/.config" ]]

printf 'PASS: empty home initialized; existing home left untouched.\\n'
