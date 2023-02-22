// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { PRBProxyFactory_Test } from "../PRBProxyFactory.t.sol";

contract Version_Test is PRBProxyFactory_Test {
    /// @dev it should return the release version.
    function test_Version() external {
        uint256 actualVersion = factory.VERSION();
        uint256 expectedVersion = 3;
        assertEq(actualVersion, expectedVersion, "VERSION");
    }
}
