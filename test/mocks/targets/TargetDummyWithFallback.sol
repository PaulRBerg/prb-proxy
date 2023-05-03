// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetDummyWithFallback is PRBProxyStorage {
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
