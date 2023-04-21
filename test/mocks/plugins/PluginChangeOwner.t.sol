// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetChangeOwner } from "../targets/TargetChangeOwner.t.sol";

contract PluginChangeOwner is IPRBProxyPlugin, TargetChangeOwner {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.changeIt.selector;
        return methods;
    }
}
