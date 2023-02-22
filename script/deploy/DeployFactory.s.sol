// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { PRBProxyFactory } from "../../src/PRBProxyFactory.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxyFactory} contract at a deterministic address across all chains. Reverts if the contract
/// has already been deployed.
contract DeployFactory is Script, BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyFactory proxy) {
        proxy = new PRBProxyFactory{ salt: ZERO_SALT }();
    }
}
