// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyHelpers
/// @notice The enshrined target contract, which contains essential helper functions for:
/// - Permitting envoys to call target contracts on behalf of the proxy.
/// - Installing plugins on the proxy.
/// - Uninstalling plugins on the proxy.
interface IPRBProxyHelpers {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the plugin has no listed methods.
    error PRBProxy_NoPluginMethods(IPRBProxyPlugin plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a plugin is installed.
    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                      PLUGINS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Installs the provided plugin contract.
    ///
    /// @dev Emits an {InstallPlugin} event.
    ///
    /// Requirements:
    /// - The plugin must have at least one listed method.
    /// - By design, the plugin cannot implement any method that is also implemented by the proxy itself.
    ///
    /// Notes:
    /// - Does not revert if the plugin is already installed.
    /// - Installing a plugin is a potentially dangerous operation, because anyone can then call the plugin's methods.
    ///
    /// @param plugin The address of the plugin to install.
    function installPlugin(IPRBProxyPlugin plugin) external;

    /// @notice Uninstalls the provided plugin contract.
    ///
    /// @dev Emits an {UninstallPlugin} event.
    ///
    /// Requirements:
    /// - The plugin must have at least one listed method.
    ///
    /// Notes:
    /// - Does not revert if the plugin is not already installed.
    ///
    /// @param plugin The address of the plugin to uninstall.
    function uninstallPlugin(IPRBProxyPlugin plugin) external;
}
