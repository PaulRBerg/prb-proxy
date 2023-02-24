// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Helpers_Test } from "../Helpers.t.sol";

contract Version_Test is Helpers_Test {
    function test_Versions() external {
        uint256 factoryVersion = factory.VERSION();
        uint256 helpersVersion = helpers.VERSION();
        assertEq(factoryVersion, helpersVersion, "Factory version does not match helpers version");
    }
}
