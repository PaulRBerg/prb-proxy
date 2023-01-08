// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

contract TargetChangeOwner {
    address public owner;

    function changeOwner() external {
        owner = address(0);
    }
}
