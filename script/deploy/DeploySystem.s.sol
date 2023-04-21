// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyHelpers } from "../../src/PRBProxyHelpers.sol";
import { PRBProxyRegistry } from "../../src/PRBProxyRegistry.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @dev Deploys {PRBProxyRegistry} and {PRBProxyHelpers} at deterministic addresses across chains.
/// @dev Reverts if any contract has already been deployed.
contract DeploySystem is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyRegistry registry, PRBProxyHelpers helpers) {
        registry = new PRBProxyRegistry{ salt: ZERO_SALT }();
        helpers = new PRBProxyHelpers{ salt: ZERO_SALT }();
    }
}
