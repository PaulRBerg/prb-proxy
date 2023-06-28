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
cp out-optimized/PRBProxy.sol/PRBProxy.json $artifacts
cp out-optimized/PRBProxyRegistry.sol/PRBProxyRegistry.json $artifacts

interfaces=./artifacts/interfaces
cp out-optimized/IPRBProxy.sol/IPRBProxy.json $interfaces
cp out-optimized/IPRBProxyPlugin.sol/IPRBProxyPlugin.json $interfaces
cp out-optimized/IPRBProxyRegistry.sol/IPRBProxyRegistry.json $interfaces

# Format the artifacts with Prettier
pnpm prettier --write ./artifacts
