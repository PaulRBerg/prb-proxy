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

    /// @inheritdoc IPRBProxyStorage
    mapping(address envoy => mapping(address target => bool permission)) public permissions;

    /// @inheritdoc IPRBProxyStorage
    mapping(bytes4 method => IPRBProxyPlugin plugin) public plugins;
}
