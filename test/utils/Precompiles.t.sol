// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { Base_Test } from "../Base.t.sol";
import { Precompiles } from "./Precompiles.sol";

contract Precompiles_Test is Base_Test {
    Precompiles internal precompiles = new Precompiles();

    modifier onlyTestOptimizedProfile() {
        if (isTestOptimizedProfile()) {
            _;
        }
    }

    function test_DeployPRBProxyRegistry() external onlyTestOptimizedProfile {
        address actualRegistry = address(precompiles.deployRegistry());
        address expectedRegistry = address(deployOptimizedRegistry());
        assertEq(actualRegistry.code, expectedRegistry.code, "registry bytecodes don't match");
    }
}
