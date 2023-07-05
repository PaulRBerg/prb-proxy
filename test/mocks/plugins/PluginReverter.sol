// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetReverter } from "../targets/TargetReverter.sol";

contract PluginReverter is IPRBProxyPlugin, TargetReverter {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](5);

        methods[0] = this.withNothing.selector;
        methods[1] = this.withCustomError.selector;
        methods[2] = this.withRequire.selector;
        methods[3] = this.withReasonString.selector;
        methods[4] = this.notPayable.selector;

        return methods;
    }
}
