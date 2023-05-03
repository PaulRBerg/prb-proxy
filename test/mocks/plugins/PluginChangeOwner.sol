// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyPlugin } from "../../../src/abstracts/PRBProxyPlugin.sol";

import { TargetChangeOwner } from "../targets/TargetChangeOwner.sol";

contract PluginChangeOwner is PRBProxyPlugin, TargetChangeOwner {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.changeIt.selector;
        return methods;
    }
}
