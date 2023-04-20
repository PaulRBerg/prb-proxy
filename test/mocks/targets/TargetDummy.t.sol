// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

contract TargetDummy {
    function foo() external pure returns (string memory) {
        return "foo";
    }

    function bar() external pure returns (string memory) {
        return "bar";
    }
}
