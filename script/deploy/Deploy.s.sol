// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { PRBProxyFactory } from "../../src/PRBProxyFactory.sol";
import { PRBProxyRegistry } from "../../src/PRBProxyRegistry.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @dev Deploys the {PRBProxyFactory} and the {PRBProxyRegistry} contracts at deterministic addresses across all
/// chains. Reverts if any of the two contracts has already been deployed.
contract Deploy is Script, BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyFactory factory, PRBProxyRegistry registry) {
        factory = new PRBProxyFactory{ salt: ZERO_SALT }();
        registry = new PRBProxyRegistry{ salt: ZERO_SALT }(factory);
    }
}
