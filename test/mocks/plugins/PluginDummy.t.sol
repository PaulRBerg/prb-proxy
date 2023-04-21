// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetDummy } from "../targets/TargetDummy.t.sol";

contract PluginDummy is IPRBProxyPlugin, TargetDummy {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](2);
        methods[0] = this.foo.selector;
        methods[1] = this.bar.selector;
        return methods;
    }
}
