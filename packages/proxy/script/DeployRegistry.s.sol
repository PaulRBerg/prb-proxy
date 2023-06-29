// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployRegistry is BaseScript {
    function run() public virtual broadcaster returns (PRBProxyRegistry registry) {
        registry = new PRBProxyRegistry();
    }
}
