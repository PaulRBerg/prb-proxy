// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { IPRBProxyRegistry } from "../src/interfaces/IPRBProxyRegistry.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Permits an envoy to delegate call to a target contract.
contract SetPermission is BaseScript {
    function run(IPRBProxyRegistry registry, address target, bool permission) public broadcast {
        address envoy = vm.addr(vm.deriveKey({ mnemonic: mnemonic, index: 1 }));
        registry.setPermission({ envoy: envoy, target: target, permission: permission });
    }
}
