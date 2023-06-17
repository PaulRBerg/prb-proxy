// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/// @title IPRBProxyPlugin
/// @notice Interface for plugin contracts that can be installed on a proxy.
/// @dev Plugins are contracts that enable the proxy to interact with and respond to calls from other contracts. These
/// plugins are run in the proxy's fallback function.
///
/// This interface is meant to be directly inherited by plugin implementations.
interface IPRBProxyPlugin {
    /// @notice Enumerates the methods implemented by the plugin.
    /// @dev These methods can be installed and uninstalled.
    ///
    /// Requirements:
    /// - The plugin must implement at least one method.
    ///
    /// @return methods An array of the methods implemented by the plugin.
    function methodList() external returns (bytes4[] memory methods);
}
