// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyStorage
/// @dev Interface for accessing the proxy's storage.
interface IPRBProxyStorage {
    /// @notice The address of the owner account or contract.
    function owner() external view returns (address);

    /// @notice The amount of gas to reserve for running the remainder of either the fallback or the execute
    /// function after the delegate call.
    /// @dev This precaution ensures that the proxy remains operational even if EVM opcode gas costs change in the
    /// future.
    function minGasReserve() external view returns (uint256);

    /// @notice The address of the plugin contract installed for the provided method.
    /// @dev The zero address is returned if no plugin contract is installed.
    /// @param method The method's signature for the query.
    function plugins(bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice A boolean flag that indicates whether the envoy has permission to call the provided target contract.
    function permissions(address envoy, address target) external view returns (bool permission);
}
