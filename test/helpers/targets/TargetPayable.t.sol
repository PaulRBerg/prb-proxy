// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract TargetPayable {
    function revertLackPayableModifier() external payable returns (uint256) {
        return 0;
    }
}
