// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

/// @title Events
/// @notice Abstract contract that contains all the events emitted by the protocol.
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    event SetMinGasReserve(uint256 oldMinGasReserve, uint256 newMinGasReserve);

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

    event TransferOwnership(IPRBProxy proxy, address indexed oldOwner, address indexed newOwner);
}
