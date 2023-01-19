// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { Base_Test } from "../Base.t.sol";

/// @notice Dummy contract only needed for providing naming context in the test traces.
abstract contract PRBProxyRegistry_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }
}
