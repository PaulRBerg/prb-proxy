// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";

/// @notice Abstract contract with the storage layout of the {PRBProxy} contract.
/// @dev This contract is an exact replica of the storage layout of {PRBProxy}, and it exists so that it can
/// be inherited in target contracts. However, to avoid overcomplicating the inheritance structure, this is
/// not inherited by the {PRBProxy} contract itself.
abstract contract PRBProxyStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the owner account or contract.
    address public owner;

    /// @notice How much gas to reserve for running the remainder of the "execute" function after the DELEGATECALL.
    /// @dev This prevents the proxy from becoming unusable if EVM opcode gas costs change in the future.
    uint256 public minGasReserve;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Maps plugin methods to plugin implementation.
    mapping(bytes4 method => IPRBProxyPlugin plugin) internal plugins;

    /// @dev Maps envoys to target contracts to function selectors to boolean flags.
    mapping(address envoy => mapping(address target => bool permission)) internal permissions;
}
