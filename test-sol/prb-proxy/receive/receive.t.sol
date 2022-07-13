// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBProxyTest } from "../PRBProxyTest.t.sol";

contract PRBProxy__Receive is PRBProxyTest {
    /// @dev it should say that the call was not successful.
    function testCannotReceive__CallDataNonEmpty() external {
        uint256 value = 1 ether;
        bytes memory data = bytes.concat("0xcafe");
        (bool actualCondition, ) = address(prbProxy).call{ value: value }(data);
        bool expectedCondition = false;
        assertEq(actualCondition, expectedCondition);
    }

    modifier CallDataEmpty() {
        _;
    }

    /// @dev it should receive the ETH.
    function testReceive() external CallDataEmpty {
        uint256 value = 1 ether;
        (bool actualCondition, ) = address(prbProxy).call{ value: value }("");
        bool expectedCondition = true;
        assertEq(actualCondition, expectedCondition);

        uint256 actualBalance = address(prbProxy).balance;
        uint256 expectedBalance = value;
        assertEq(actualBalance, expectedBalance);
    }
}
