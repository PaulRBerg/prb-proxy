// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";
import { TargetPanic } from "../targets/TargetPanic.sol";

contract PluginPanic is IPRBProxyPlugin, TargetPanic {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](4);

        methods[0] = this.failedAssertion.selector;
        methods[1] = this.arithmeticOverflow.selector;
        methods[2] = this.divisionByZero.selector;
        methods[3] = this.indexOOB.selector;

        return methods;
    }
}
