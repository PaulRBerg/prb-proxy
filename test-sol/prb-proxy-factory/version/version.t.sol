// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBProxyFactoryTest } from "../PRBProxyFactoryTest.t.sol";

contract PRBProxyFactory__Version is PRBProxyFactoryTest {
    /// @dev it should return the version.
    function testVersion() external {
        uint256 actualVersion = prbProxyFactory.version();
        uint256 expectedVersion = 3;
        assertEq(actualVersion, expectedVersion);
    }
}
