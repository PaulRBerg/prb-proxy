// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

contract PluginSablier is IPRBProxyPlugin {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.onStreamCanceled.selector;
        return methods;
    }

    /// @dev The 4-byte selector for this method is 0x72eba203.
    function onStreamCanceled(uint256, address, uint128, uint128) external pure { }
}
