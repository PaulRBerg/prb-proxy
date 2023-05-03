// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetPayable is PRBProxyStorage {
    function revertLackPayableModifier() external payable returns (uint256) {
        return 0;
    }
}
