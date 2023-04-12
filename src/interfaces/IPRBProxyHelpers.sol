// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyHelpers
/// @notice The enshrined target contract, which implements helper functions for the following operations:
/// - Installing plugins on the proxy.
/// - Updating the minimum gas reserve.
/// - Permitting envoys to call target contracts on behalf of the proxy.
/// - Uninstalling plugins on the proxy.
interface IPRBProxyHelpers {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when installing or uninstall a plugin, and the plugin doesn't implement any method.
    error PRBProxy_NoPluginMethods(IPRBProxyPlugin plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a plugin is installed.
    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    /// @notice Emitted when the minimum gas reserve is updated.
    event SetMinGasReserve(uint256 oldMinGasReserve, uint256 newMinGasReserve);

    /// @notice Emitted when the permission is updated for an (envoy,target) tuple.
    event SetPermission(address indexed envoy, address indexed target, bool permission);

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The semantic version of the {PRBProxy} release.
    /// @dev This is mirrored here to serve as a link to the proxy registry.
    function VERSION() external view returns (string memory);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Installs the provided plugin contract.
    ///
    /// @dev Emits an {InstallPlugin} event.
    ///
    /// Notes:
    /// - Does not revert if the plugin is installed.
    /// - Installing a plugin is a potentially dangerous operation, because anyone can then call the plugin's methods.
    ///
    /// Requirements:
    /// - The plugin must have at least one implemented method.
    /// - By design, the plugin cannot implement any method that is also implemented by the proxy itself.
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
    /// - It is not an error to set the same permission.
    ///
    /// @param envoy The address of the envoy account.
    /// @param target The address of the target contract.
    /// @param permission The boolean permission to set.
    function setPermission(address envoy, address target, bool permission) external;

    /// @notice Uninstalls the provided plugin contract.
    ///
    /// @dev Emits an {UninstallPlugin} event.
    ///
    /// Notes:
    /// - Does not revert if the plugin is not installed.
    ///
    /// Requirements:
    /// - The plugin must have at least one implemented method.
    ///
    ///
    /// @param plugin The address of the plugin to uninstall.
    function uninstallPlugin(IPRBProxyPlugin plugin) external;
}
