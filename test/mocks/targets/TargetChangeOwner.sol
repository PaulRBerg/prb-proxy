// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

contract TargetChangeOwner {
    address public owner;

    function changeIt() external {
        owner = address(1729);
    }
}
