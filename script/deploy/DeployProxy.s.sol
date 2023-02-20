// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { Script } from "forge-std/Script.sol";

import { PRBProxy } from "src/PRBProxy.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxy} contract.
contract DeployProxy is Script, BaseScript {
    function run() public virtual broadcaster returns (PRBProxy proxy) {
        proxy = new PRBProxy();
    }
}
