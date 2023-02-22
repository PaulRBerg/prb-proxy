// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { IPRBProxyFactory } from "../../src/interfaces/IPRBProxyFactory.sol";
import { PRBProxyRegistry } from "../../src/PRBProxyRegistry.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxyFactory} contract at a deterministic address across all chains. Reverts if the contract
/// has already been deployed.
contract DeployRegistry is Script, BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(IPRBProxyFactory factory) public virtual broadcaster returns (PRBProxyRegistry registry) {
        registry = new PRBProxyRegistry{ salt: ZERO_SALT }(factory);
    }
}
