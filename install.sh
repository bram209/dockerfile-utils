#!/bin/bash

read -p "Do you wish to see the content of this script before execution?" -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  tail -n +20 "$0"

  echo
  read -p "Continue? " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]
  then
    exit
  fi
fi

echo "INSTALL"
curl -sS https://raw.githubusercontent.com/bram209/dockerfile-utils/main/gen_aspnet_dockerfile.sh | sudo tee -a /usr/local/bin/gen_aspnet_dockerfile &>/dev/null && echo "Installed gen_aspnet_dockerfile into /usr/local/bin"
