// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

/// @title IPRBProxyPlugin
/// @notice Interface for the plugins that can be installed on a proxy.
interface IPRBProxyPlugin {
    /// @notice Lists the methods that the plugin implements.
    /// @dev These methods are installed and uninstalled by the proxy.
    ///
    /// Requirements:
    /// - The plugin needs at least one method to be listed.
    ///
    /// @return methods The methods that the plugin implements.
    function methodList() external returns (bytes4[] memory methods);
}
