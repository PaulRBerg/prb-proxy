// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "../../src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "../../src/interfaces/IPRBProxyPlugin.sol";

/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                       PROXY
    //////////////////////////////////////////////////////////////////////////*/

    event Execute(address indexed target, bytes data, bytes response);

    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    /*//////////////////////////////////////////////////////////////////////////
                                      REGISTRY
    //////////////////////////////////////////////////////////////////////////*/

    event DeployProxy(address indexed operator, address indexed owner, IPRBProxy proxy);

    event InstallPlugin(address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin);

    event SetPermission(
        address indexed owner, IPRBProxy indexed proxy, address indexed envoy, address target, bool permission
    );

    event UninstallPlugin(address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin);
}
