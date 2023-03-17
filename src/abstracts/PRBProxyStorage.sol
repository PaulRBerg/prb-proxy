// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyStorage } from "../interfaces/IPRBProxyStorage.sol";

/// @title PRBProxyStorage
/// @dev This contract implements the {IPRBProxyStorage} interface, and it is meant to be inherited by target contracts.
abstract contract PRBProxyStorage is IPRBProxyStorage {
    /// @inheritdoc IPRBProxyStorage
    address public override owner;

    /// @inheritdoc IPRBProxyStorage
    uint256 public override minGasReserve;

    /// @inheritdoc IPRBProxyStorage
    mapping(bytes4 method => IPRBProxyPlugin plugin) public plugins;

    /// @inheritdoc IPRBProxyStorage
    mapping(address envoy => mapping(address target => bool permission)) public permissions;
}
