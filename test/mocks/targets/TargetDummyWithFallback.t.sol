// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

contract TargetDummyWithFallback {
    event LogFallback();

    fallback() external payable {
        emit LogFallback();
    }

    receive() external payable { }

    function foo() external pure returns (string memory) {
        return "foo";
    }

    function bar() external pure returns (string memory) {
        return "bar";
    }
}
