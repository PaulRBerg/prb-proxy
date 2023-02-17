// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

contract TargetChangeOwner {
    address public owner;

    function changeIt() external {
        owner = address(1729);
    }
}
