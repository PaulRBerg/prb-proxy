// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Registry_Test } from "../Registry.t.sol";

contract Version_Test is Registry_Test {
    /// @dev it should return the release version.
    function test_Version() external {
        uint256 actualVersion = registry.VERSION();
        uint256 expectedVersion = 4;
        assertEq(actualVersion, expectedVersion, "VERSION");
    }
}
