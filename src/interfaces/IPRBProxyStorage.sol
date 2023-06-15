// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyStorage
/// @dev Interface for accessing the proxy's storage.
interface IPRBProxyStorage {
    /// @notice The address of the owner account or contract.
    function owner() external view returns (address);

    /// @notice The address of the plugin contract installed for the provided method.
    /// @dev The zero address is returned if no plugin contract is installed.
    /// @param method The method's signature for the query.
    function plugins(bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice A boolean flag that indicates whether the envoy has permission to call the provided target contract.
    function permissions(address envoy, address target) external view returns (bool permission);
}
