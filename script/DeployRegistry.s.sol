// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Deploys {PRBProxyRegistry} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployRegistry is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyRegistry registry) {
        registry = new PRBProxyRegistry{ salt: ZERO_SALT }();
    }
}
