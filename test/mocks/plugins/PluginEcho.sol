// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../../../src/interfaces/IPRBProxyPlugin.sol";

import { TargetEcho } from "../targets/TargetEcho.sol";

contract PluginEcho is IPRBProxyPlugin, TargetEcho {
    function getMethods() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](9);

        methods[0] = this.echoAddress.selector;
        methods[1] = this.echoBytesArray.selector;
        methods[2] = this.echoBytes32.selector;
        methods[3] = this.echoMsgValue.selector;
        methods[4] = this.echoString.selector;
        methods[5] = this.echoStruct.selector;
        methods[6] = this.echoUint8.selector;
        methods[7] = this.echoUint256.selector;
        methods[8] = this.echoUint256Array.selector;

        return methods;
    }
}
