// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { IPRBProxy } from "../src/interfaces/IPRBProxy.sol";
import { IPRBProxyAnnex } from "../src/interfaces/IPRBProxyAnnex.sol";

import { BaseScript } from "./Base.s.sol";

/// @notice Bootstraps the proxy system by giving permission to an envoy and installing a plugin.
contract SetPermission is BaseScript {
    function run(
        IPRBProxy proxy,
        IPRBProxyAnnex annex,
        address target
    )
        public
        broadcaster
        returns (bytes memory response)
    {
        // ABI encode the call to `setPermission`.
        address envoy = vm.addr(vm.deriveKey(mnemonic, 1));
        bool permission = true;
        bytes memory data = abi.encodeCall(annex.setPermission, (envoy, target, permission));

        // Execute the call to the annex.
        response = proxy.execute(address(annex), data);
    }
}
