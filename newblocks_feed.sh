#!/bin/bash
server=${1:-"virginia.solana.blxrbdn.com"}
authorization=${2:-""}
filter=${3:-""}

wscat_exist=$(which wscat)

if [[ "${wscat_exist}" ==  "" ]]; then
  echo "Please install wscat"
  exit 1
fi

authorization_header=""
if [[ "${authorization}" != "" ]]; then
  if [[ "${authorization}" =~ ":" ]]; then
    authorization_header="--header '${authorization}'"
  else
    authorization_header="--header 'authorization:${authorization}'"
  fi
fi

wscat -c wss://${server}/ws ${authorization_header} --execute '{"method":"subscribe", "params": ["newBlocks", {"include": []}]}'
