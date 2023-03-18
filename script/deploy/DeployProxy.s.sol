// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { IPRBProxy } from "../../src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "../../src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxyHelpers } from "../../src/PRBProxyHelpers.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Deploys the {PRBProxy} contract by calling the `deploy` function on the registry.
contract DeployProxy is BaseScript {
    function run(IPRBProxyRegistry registry) public virtual broadcaster returns (IPRBProxy proxy) {
        proxy = registry.deploy();
    }
}
