// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxy } from "../../src/interfaces/IPRBProxy.sol";
import { IPRBProxyHelpers } from "../../src/interfaces/IPRBProxyHelpers.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @notice Bootstraps the proxy system by giving permission to an envoy and installing a plugin.
contract SetPermission is BaseScript {
    function run(
        IPRBProxy proxy,
        IPRBProxyHelpers helpers,
        address target
    )
        public
        broadcaster
        returns (bytes memory response)
    {
        // ABI encode the call to `setPermission`.
        address envoy = vm.addr(vm.deriveKey(mnemonic, 1));
        bool permission = true;
        bytes memory data = abi.encodeCall(helpers.setPermission, (envoy, target, permission));

        // Execute the call to the enshrined target.
        response = proxy.execute(address(helpers), data);
    }
}
