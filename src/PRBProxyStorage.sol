// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";

/// @notice Abstract contract with the storage layout of the {PRBProxy} contract.
/// @dev This is kept separate so that developers can inherit it in their own target contracts.
abstract contract PRBProxyStorage is IPRBProxy {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    address public override owner;

    /// @inheritdoc IPRBProxy
    uint256 public override minGasReserve;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Maps plugin methods to plugin implementation.
    mapping(bytes4 method => IPRBProxyPlugin plugin) internal plugins;

    /// @dev Maps envoys to target contracts to function selectors to boolean flags.
    mapping(address envoy => mapping(address target => mapping(bytes4 selector => bool permission)))
        internal permissions;
}
