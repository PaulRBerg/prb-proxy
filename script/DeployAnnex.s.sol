// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyAnnex } from "../src/PRBProxyAnnex.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Deploys {PRBProxyAnnex} at a deterministic address across all chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployAnnex is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyAnnex annex) {
        annex = new PRBProxyAnnex{ salt: ZERO_SALT }();
    }
}
