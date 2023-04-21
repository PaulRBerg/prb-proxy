// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

contract PluginEmpty is IPRBProxyPlugin {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](0);
        return methods;
    }
}
