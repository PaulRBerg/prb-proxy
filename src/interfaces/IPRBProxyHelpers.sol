// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyHelpers
/// @notice The enshrined target contract, with essential helper functions for:
/// - Installing plugins on the proxy.
/// - Updating the minimum gas reserve.
/// - Permitting envoys to call target contracts on behalf of the proxy.
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

    /// @notice Emitted when the minimum gas reserve is updated.
    event SetMinGasReserve(uint256 oldMinGasReserve, uint256 newMinGasReserve);

    /// @notice Emitted when the permission is set for an (envoy,target) tuple.
    event SetPermission(address indexed envoy, address indexed target, bool permission);

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The release version of the {PRBProxy} protocol.
    /// @dev This version is mirrored here to serve as a link to the proxy registry.
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

    /// @notice Sets a new value for the minimum gas reserve.
    ///
    /// @dev Emits a {SetMinGasReserve} event.
    ///
    /// @param newMinGasReserve The new minimum gas reserve.
    function setMinGasReserve(uint256 newMinGasReserve) external;

    /// @notice Gives or takes a permission from an envoy to call the provided target contract and function selector
    /// on behalf of the proxy owner.
    ///
    /// @dev Emits a {SetPermission} event.
    ///
    /// Notes:
    /// - It is not an error to reset a permission on the same (envoy,target) tuple.
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
