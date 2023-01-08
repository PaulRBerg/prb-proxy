// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { BaseTest } from "../BaseTest.t.sol";

/// @notice Dummy contract only needed for providing naming context in the test traces.
abstract contract PRBProxyRegistry_Test is BaseTest {
    function setUp() public virtual override {
        BaseTest.setUp();
    }
}
