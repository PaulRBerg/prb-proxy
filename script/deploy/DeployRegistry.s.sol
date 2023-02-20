// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { IPRBProxyFactory } from "src/interfaces/IPRBProxyFactory.sol";
import { PRBProxyRegistry } from "src/PRBProxyRegistry.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxyRegistry} contract.
contract DeployRegistry is Script, BaseScript {
    function run(IPRBProxyFactory factory) public virtual broadcaster returns (PRBProxyRegistry registry) {
        registry = new PRBProxyRegistry(factory);
    }
}
