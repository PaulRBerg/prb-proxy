// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyHelpers } from "../../src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyRegistry } from "../../src/interfaces/IPRBProxyRegistry.sol";

import { Base_Test } from "../Base.t.sol";
import { Precompiles } from "./Precompiles.sol";

contract Precompiles_Test is Base_Test {
    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployPRBProxyHelpers() external onlyTestOptimizedProfile {
        address actualHelpers = address(precompiles.deployPRBProxyHelpers());
        address expectedHelpers = address(deployPrecompiledHelpers());
        assertEq(actualHelpers.code, expectedHelpers.code, "proxy helpers bytecodes don't match");
    }

    function test_DeployPRBProxyRegistry() external onlyTestOptimizedProfile {
        address actualRegistry = address(precompiles.deployPRBProxyRegistry());
        address expectedRegistry = address(deployPrecompiledRegistry());
        assertEq(actualRegistry.code, expectedRegistry.code, "registry bytecodes don't match");
    }

    function test_DeployPRBProxySystem() external onlyTestOptimizedProfile {
        (IPRBProxyRegistry actualRegistry, IPRBProxyHelpers actualHelpers) = precompiles.deployPRBProxySystem();
        address expectedHelpers = address(deployPrecompiledHelpers());
        address expectedRegistry = address(deployPrecompiledRegistry());
        assertEq(address(actualHelpers).code, expectedHelpers.code, "proxy helpers bytecodes don't match");
        assertEq(address(actualRegistry).code, expectedRegistry.code, "registry bytecodes don't match");
    }
}
