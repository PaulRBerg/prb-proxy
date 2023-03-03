// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { PRBProxyHelpers } from "../../src/PRBProxyHelpers.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxyHelpers} contract at a deterministic address across all chains. Reverts if the contract
/// has already been deployed.
contract DeployHelpers is Script, BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyHelpers helpers) {
        helpers = new PRBProxyHelpers{ salt: ZERO_SALT }();
    }
}
