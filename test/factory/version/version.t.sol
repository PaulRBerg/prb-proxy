// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Factory_Test } from "../Factory.t.sol";

contract Version_Test is Factory_Test {
    /// @dev it should return the release version.
    function test_Version() external {
        uint256 actualVersion = factory.VERSION();
        uint256 expectedVersion = 4;
        assertEq(actualVersion, expectedVersion, "VERSION");
    }
}
