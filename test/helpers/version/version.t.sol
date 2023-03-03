// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Helpers_Test } from "../Helpers.t.sol";

contract Version_Test is Helpers_Test {
    function test_Versions() external {
        string memory registryVersion = registry.VERSION();
        string memory helpersVersion = helpers.VERSION();
        assertEq(registryVersion, helpersVersion, "Registry version does not match helpers version");
    }
}
