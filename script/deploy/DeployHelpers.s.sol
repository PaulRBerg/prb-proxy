// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyHelpers } from "../../src/PRBProxyHelpers.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys {PRBProxyHelpers} at a deterministic address across all chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployHelpers is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyHelpers helpers) {
        helpers = new PRBProxyHelpers{ salt: ZERO_SALT }();
    }
}
