// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Annex_Test } from "../Annex.t.sol";

contract Version_Test is Annex_Test {
    function test_Versions() external {
        string memory actualVersion = annex.VERSION();
        string memory expectedVersion = "4.0.0-beta.4";
        assertEq(actualVersion, expectedVersion, "annex version mismatch");
    }
}
