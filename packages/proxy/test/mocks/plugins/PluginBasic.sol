// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetBasic } from "../targets/TargetBasic.sol";

contract PluginBasic is IPRBProxyPlugin, TargetBasic {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](2);
        methods[0] = this.foo.selector;
        methods[1] = this.bar.selector;
        return methods;
    }
}
