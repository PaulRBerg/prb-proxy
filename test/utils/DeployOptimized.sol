// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { StdCheats } from "forge-std/src/StdCheats.sol";

import { IPRBProxyRegistry } from "../../src/interfaces/IPRBProxyRegistry.sol";

abstract contract DeployOptimized is StdCheats {
    /// @dev Deploys {PRBProxyRegistry} from an optimized source compiled `--via-ir`.
    function deployOptimizedRegistry() internal returns (IPRBProxyRegistry registry_) {
        registry_ = IPRBProxyRegistry(deployCode("out-optimized/PRBProxyRegistry.sol/PRBProxyRegistry.json"));
    }
}
