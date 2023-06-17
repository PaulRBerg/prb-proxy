// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "../../src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "../../src/interfaces/IPRBProxyPlugin.sol";

/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                       ANNEX
    //////////////////////////////////////////////////////////////////////////*/

    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    event SetPermission(address indexed envoy, address indexed target, bool permission);

    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                       PROXY
    //////////////////////////////////////////////////////////////////////////*/

    event Execute(address indexed target, bytes data, bytes response);

    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    /*//////////////////////////////////////////////////////////////////////////
                                      REGISTRY
    //////////////////////////////////////////////////////////////////////////*/

    event DeployProxy(
        address indexed origin,
        address indexed operator,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        IPRBProxy proxy
    );
}
