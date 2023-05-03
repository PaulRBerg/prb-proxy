// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyPlugin } from "../../../src/abstracts/PRBProxyPlugin.sol";

import { TargetSelfDestructer } from "../targets/TargetSelfDestructer.sol";

contract PluginSelfDestructer is PRBProxyPlugin, TargetSelfDestructer {
    function methodList() external pure override returns (bytes4[] memory) {
        bytes4[] memory methods = new bytes4[](1);
        methods[0] = this.destroyMe.selector;
        return methods;
    }
}
