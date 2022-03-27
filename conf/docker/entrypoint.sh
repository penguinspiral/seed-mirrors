#!/usr/bin/env bash
set -e

export GNUPGHOME=$(mktemp --directory /tmp/.gnupgXXX)

declare -r LOG_FILE="./seed-mirrors-$(date +%T:%F).log"
declare -r MIRRORS_CONF_ROOT="./conf/debmirror"
declare -a MIRRORS_CONF=( $(find ${MIRRORS_CONF_ROOT}/**/ -type f -name *.conf) )
declare -r GPG_KEYS_ROOT="./conf/gpg.d"
declare -a GPG_KEYS=( $(find ${GPG_KEYS_ROOT}/ -type f -name *.gpg) )

function title() {
  printf "\n\033[1m=== $1 ===\033[0m\n"
}

function die() {
  printf "\n\033[0;31mERROR:\033[0m $1.\n"
  printf "\033[0;33mLogging: \033[0m: ${LOG_FILE}\n"
  exit 1
}

function validate() {
  if [[ "${TARGET}" != "all" ]]; then
    title "Validating targeted mirrors"

    declare -a TARGET_MIRRORS_CONF=() 
    for mirror in ${TARGET[@]}; do
      conf="${MIRRORS_CONF_ROOT}/${mirror}.conf"
      printf "Mirror \'${mirror}\' configuration: ${conf}... "
      stat "${conf}" &>>${LOG_FILE} || die "Missing debmirror configuration for mirror: ${mirror}"
      TARGET_MIRRORS_CONF+=( "${conf}" )
      printf "\033[32mfound!\033[0m\n"
    done

    MIRRORS_CONF=( ${TARGET_MIRRORS_CONF[@]} )
  fi
}

function import() {
  title "Importing GPG Keys"
  for key in "${GPG_KEYS[@]}"; do
    printf "Importing GPG key: ${key}... "
    gpg --no-default-keyring \
        --keyring "${GNUPGHOME}/trustedkeys.kbx" \
        --import "${key}" &>>${LOG_FILE} || die "Failed to import GPG key: ${key}"
    printf "\033[32msuccess!\033[0m\n"
  done

  title "GPG Keyring list"
  gpg --list-keys \
      --no-default-keyring \
      --keyring "${GNUPGHOME}/trustedkeys.kbx" |& tee --append "${LOG_FILE}"
}

function mirror() {
  title "Syncing mirrors"
  for mirror in "${MIRRORS_CONF[@]}"; do
    printf "Mirroring remote repository: ${mirror}... "
    debmirror --config-file ${mirror} \
              --debug &>>${LOG_FILE} || die "Failed to sync mirror: ${mirror}"
    printf "\033[32msuccess!\033[0m\n"
  done
}

function main() {
  validate;
  import;
  mirror;
}

main;
