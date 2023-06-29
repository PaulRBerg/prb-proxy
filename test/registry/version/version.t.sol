// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Registry_Test } from "../Registry.t.sol";

contract Version_Test is Registry_Test {
    function test_Version() external {
        string memory actualVersion = registry.VERSION();
        string memory expectedVersion = "4.0.0-beta.6";
        assertEq(actualVersion, expectedVersion, "registry version mismatch");
    }
}
