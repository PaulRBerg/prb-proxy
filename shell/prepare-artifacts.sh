#!/usr/bin/env bash

# Notes:
# - The script must be run from the repo's root directory

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - pnpm (https://pnpm.io)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Delete the current artifacts
artifacts=./artifacts
rm -rf $artifacts

# Create the new artifacts directories
mkdir $artifacts "$artifacts/interfaces"

# Generate the artifacts with Forge
FOUNDRY_PROFILE=optimized forge build

# Copy the production artifacts
cp optimized-out/PRBProxy.sol/PRBProxy.json $artifacts
cp optimized-out/PRBProxyAnnex.sol/PRBProxyAnnex.json $artifacts
cp optimized-out/PRBProxyRegistry.sol/PRBProxyRegistry.json $artifacts

interfaces=./artifacts/interfaces
cp optimized-out/IPRBProxy.sol/IPRBProxy.json $interfaces
cp optimized-out/IPRBProxyAnnex.sol/IPRBProxyAnnex.json $interfaces
cp optimized-out/IPRBProxyPlugin.sol/IPRBProxyPlugin.json $interfaces
cp optimized-out/IPRBProxyRegistry.sol/IPRBProxyRegistry.json $interfaces
cp optimized-out/IPRBProxyStorage.sol/IPRBProxyStorage.json $interfaces

# Format the artifacts with Prettier
pnpm prettier --write ./artifacts
