// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { TargetSelfDestructer } from "../targets/TargetSelfDestructer.t.sol";

contract PluginSelfDestructer is IPRBProxyPlugin, TargetSelfDestructer {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);

        methods[0] = this.destroyMe.selector;

        return methods;
    }
}
