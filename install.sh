#!/bin/bash
echo "INSTALLING"
curl -sS https://raw.githubusercontent.com/bram209/dockerfile-utils/main/gen_aspnet_dockerfile.sh | sudo tee -a /usr/local/bin/gen_aspnet_dockerfile &>/dev/null && sudo chmod +x /usr/local/bin/gen_aspnet_dockerfile  && echo "Installed gen_aspnet_dockerfile into /usr/local/bin"
