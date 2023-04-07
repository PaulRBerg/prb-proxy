// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Proxy_Test } from "../Proxy.t.sol";

contract Receive_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    function test_RevertWhen_CallDataNonEmpty() external {
        uint256 value = 1 ether;
        bytes memory data = bytes.concat("0xcafe");
        (bool condition,) = address(proxy).call{ value: value }(data);
        assertFalse(condition);
    }

    modifier whenCallDataEmpty() {
        _;
    }

    function test_Receive() external whenCallDataEmpty {
        uint256 value = 1 ether;
        (bool condition,) = address(proxy).call{ value: value }("");
        assertTrue(condition);

        uint256 actualBalance = address(proxy).balance;
        uint256 expectedBalance = value;
        assertEq(actualBalance, expectedBalance, "proxy balance");
    }
}
