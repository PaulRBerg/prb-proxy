// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

contract TargetBasic {
    function foo() external pure returns (string memory) {
        return "foo";
    }

    function bar() external pure returns (string memory) {
        return "bar";
    }
}
