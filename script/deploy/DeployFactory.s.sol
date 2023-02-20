// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { PRBProxyFactory } from "src/PRBProxyFactory.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxyFactory} contract.
contract DeployFactory is Script, BaseScript {
    function run() public virtual broadcaster returns (PRBProxyFactory proxy) {
        proxy = new PRBProxyFactory();
    }
}
