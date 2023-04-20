// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

contract TargetPayable {
    function revertLackPayableModifier() external payable returns (uint256) {
        return 0;
    }
}
