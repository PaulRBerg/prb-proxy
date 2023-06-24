// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetSelfDestructer } from "../targets/TargetSelfDestructer.sol";

contract PluginSelfDestructer is IPRBProxyPlugin, TargetSelfDestructer {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.destroyMe.selector;
        return methods;
    }
}
