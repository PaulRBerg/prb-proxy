// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IPRBProxyHelpers } from "../../src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyRegistry } from "../../src/interfaces/IPRBProxyRegistry.sol";

import { Base_Test } from "../Base.t.sol";
import { Precompiles } from "./Precompiles.sol";

contract Precompiles_Test is Base_Test {
    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployPRBProxyHelpers() external onlyTestOptimizedProfile {
        address actualHelpers = address(new Precompiles().deployPRBProxyHelpers());
        address expectedHelpers = address(deployPrecompiledHelpers());
        assertEq(actualHelpers.code, expectedHelpers.code, "proxy helpers' bytecodes don't match");
    }

    function test_DeployPRBProxyRegistry() external onlyTestOptimizedProfile {
        address actualRegistry = address(new Precompiles().deployPRBProxyRegistry());
        address expectedRegistry = address(deployPrecompiledRegistry());
        assertEq(actualRegistry.code, expectedRegistry.code, "registries' bytecodes don't match");
    }
}
