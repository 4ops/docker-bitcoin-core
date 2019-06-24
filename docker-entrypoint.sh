#!/bin/sh

set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoind"

  set -- bitcoind "$@"
fi

DATA=${BITCOIN_DATA:-/home/bitcoin/.bitcoin}

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bitcoind" ]; then
  mkdir -p "${DATA}"
  chmod 700 "${DATA}"
  chown -R bitcoin "${DATA}"

  echo "$0: setting data directory to ${DATA}"

  set -- "$@" -datadir="${DATA}"
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo
  exec su-exec bitcoin "$@"
fi

echo
exec "$@"
