// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyHelpers
/// @notice The enshrined target contract, with essential helper functions for:
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

    /// @notice Emitted when the owner sets the permission for an envoy.
    event SetPermission(address indexed envoy, address indexed target, bool permission);

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The release version of the {PRBProxy} protocol.
    /// @dev This is stored in the factory rather than the proxy to save gas for end users.
    function VERSION() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
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

    /// @notice Gives or takes a permission from an envoy to call the provided target contract and function selector
    /// on behalf of the owner.
    ///
    /// @dev It is not an error to reset a permission on the same (envoy,target) tuple multiple types.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param envoy The address of the envoy account.
    /// @param target The address of the target contract.
    /// @param permission The boolean permission to set.
    function setPermission(address envoy, address target, bool permission) external;

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
