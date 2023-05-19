// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Annex_Test } from "../Annex.t.sol";

contract Version_Test is Annex_Test {
    function test_Versions() external {
        string memory annexVersion = annex.VERSION();
        string memory registryVersion = registry.VERSION();
        assertEq(annexVersion, registryVersion, "Annex version does not match registry version");
    }
}
