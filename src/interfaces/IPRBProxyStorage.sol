// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyStorage
/// @dev Interface for accessing the storage of the proxy contract.
interface IPRBProxyStorage {
    /// @notice The address of the owner account or contract.
    function owner() external view returns (address);

    /// @notice How much gas to reserve for running the remainder of either the fallback or the "execute" function
    /// after the delegate call.
    /// @dev This prevents the proxy from becoming unusable if EVM opcode gas costs change in the future.
    function minGasReserve() external view returns (uint256);

    /// @notice The address of the plugin installed for the provided method.
    /// @dev The zero address is returned if no plugin is installed.
    /// @param method The signature of the method to make the query for.
    function plugins(bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice A boolean flag that indicates whether the envoy has permission to call the provided target contract.
    function permissions(address envoy, address target) external view returns (bool permission);
}
