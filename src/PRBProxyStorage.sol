// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyStorage } from "./interfaces/IPRBProxyStorage.sol";

/// @title PRBProxyStorage
/// @dev This contract implements the {IPRBProxyStorage} interface.
abstract contract PRBProxyStorage is IPRBProxyStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyStorage
    address public override owner;

    /// @inheritdoc IPRBProxyStorage
    uint256 public override minGasReserve;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Maps plugin methods to plugin implementation.
    mapping(bytes4 method => IPRBProxyPlugin plugin) internal plugins;

    /// @dev Maps envoys to target contracts to function selectors to boolean flags.
    mapping(address envoy => mapping(address target => bool permission)) internal permissions;

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyStorage
    function getPermission(address envoy, address target) external view override returns (bool permission) {
        permission = permissions[envoy][target];
    }

    /// @inheritdoc IPRBProxyStorage
    function getPluginForMethod(bytes4 method) external view override returns (IPRBProxyPlugin plugin) {
        plugin = plugins[method];
    }
}
