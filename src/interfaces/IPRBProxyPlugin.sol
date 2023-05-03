// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyStorage } from "./IPRBProxyStorage.sol";

/// @title IPRBProxyPlugin
/// @notice Interface for plugin contracts that can be installed on a proxy.
/// @dev Plugins are contracts that enable the proxy to interact with and respond to calls from other contracts. These
/// plugins are run in the proxy's fallback function.
///
/// A couple of notes about this interface:
///
/// - It is not meant to be inherited by plugins. Instead, plugins should inherit from {PRBProxyPlugin}.
/// - It should be used only for casting addresses to the interface type.
/// - It inherits from {IPRBProxyStorage} to enable plugins to access the proxy's storage.
interface IPRBProxyPlugin is IPRBProxyStorage {
    /// @notice Enumerates the methods implemented by the plugin.
    /// @dev These methods can be installed and uninstalled.
    ///
    /// Requirements:
    /// - The plugin must implement at least one method.
    ///
    /// @return methods An array of the methods implemented by the plugin.
    function methodList() external returns (bytes4[] memory methods);
}
