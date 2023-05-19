// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyAnnex } from "../../src/interfaces/IPRBProxyAnnex.sol";
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

    function test_DeployPRBProxyAnnex() external onlyTestOptimizedProfile {
        address actualAnnex = address(precompiles.deployAnnex());
        address expectedAnnex = address(deployPrecompiledAnnex());
        assertEq(actualAnnex.code, expectedAnnex.code, "proxy annex bytecodes don't match");
    }

    function test_DeployPRBProxyRegistry() external onlyTestOptimizedProfile {
        address actualRegistry = address(precompiles.deployRegistry());
        address expectedRegistry = address(deployPrecompiledRegistry());
        assertEq(actualRegistry.code, expectedRegistry.code, "registry bytecodes don't match");
    }

    function test_DeployPRBProxySystem() external onlyTestOptimizedProfile {
        (IPRBProxyAnnex actualAnnex, IPRBProxyRegistry actualRegistry) = precompiles.deploySystem();
        address expectedAnnex = address(deployPrecompiledAnnex());
        address expectedRegistry = address(deployPrecompiledRegistry());
        assertEq(address(actualAnnex).code, expectedAnnex.code, "proxy annex bytecodes don't match");
        assertEq(address(actualRegistry).code, expectedRegistry.code, "registry bytecodes don't match");
    }
}
