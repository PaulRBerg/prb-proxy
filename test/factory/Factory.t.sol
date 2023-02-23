// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { Base_Test } from "../Base.t.sol";

abstract contract Factory_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }
}
