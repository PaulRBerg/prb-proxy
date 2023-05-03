// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetDummy is PRBProxyStorage {
    function foo() external pure returns (string memory) {
        return "foo";
    }

    function bar() external pure returns (string memory) {
        return "bar";
    }
}
