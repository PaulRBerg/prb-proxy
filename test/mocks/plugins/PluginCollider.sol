// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

contract PluginCollider is IPRBProxyPlugin {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.onAddictionFeesRefunded.selector;
        return methods;
    }

    /// @dev The selector for this method is 0x72eba203, which is the same as the selector for
    /// `onStreamCanceled(uint256,address,uint128,uint128)`
    function onAddictionFeesRefunded(uint248 loanId, int168, uint192 feeAmount, int248) external pure {
        loanId;
        feeAmount;
    }
}
