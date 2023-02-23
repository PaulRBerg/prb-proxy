// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxy
/// @author Paul Razvan Berg
/// @notice Proxy contract to compose transactions on owner's behalf.
interface IPRBProxy {
    /*//////////////////////////////////////////////////////////////////////////
                                    CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when execution reverted with no reason.
    error PRBProxy_ExecutionReverted();

    /// @notice Emitted when the caller is not the owner.
    error PRBProxy_ExecutionUnauthorized(address owner, address caller, address target);

    /// @notice Emitted when the caller is not the owner.
    error PRBProxy_NotOwner(address owner, address caller);

    /// @notice Emitted when the plugin has no listed methods.
    error PRBProxy_NoPluginMethods(IPRBProxyPlugin plugin);

    /// @notice Emitted when the owner is changed during the DELEGATECALL.
    error PRBProxy_OwnerChanged(address originalOwner, address newOwner);

    /// @notice Emitted when a plugin execution reverts with no reason.
    error PRBProxy_PluginReverted(IPRBProxyPlugin plugin);

    /// @notice Emitted when the fallback function does not find an installed plugin for the called method.
    error PRBProxy_PluginNotInstalledForMethod(address caller, bytes4 selector);

    /// @notice Emitted when passing an EOA or an undeployed contract as the target.
    error PRBProxy_TargetNotContract(address target);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the proxy executes a delegate call to a target contract.
    event Execute(address indexed target, bytes data, bytes response);

    /// @notice Emitted when a plugin is installed.
    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    /// @notice Emitted when a plugin is run for a provided method.
    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    /// @notice Emitted when the owner sets the permission for an envoy.
    event SetPermission(address indexed envoy, address indexed target, bool permission);

    /// @notice Emitted when the owner changes the proxy's owner.
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns a boolean flag that indicates whether the envoy has permission to call the provided target
    /// contract.
    function getPermission(address envoy, address target) external view returns (bool permission);

    /// @notice Returns the address of the plugin installed for the the provided method.
    /// @dev Returns the zero address if no plugin is installed.
    /// @param method The signature of the method to make the query for.
    function getPluginForMethod(bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice How much gas to reserve for running the remainder of the "execute" function after the DELEGATECALL.
    /// @dev This prevents the proxy from becoming unusable if EVM opcode gas costs change in the future.
    function minGasReserve() external view returns (uint256);

    /// @notice The address of the owner account or contract.
    function owner() external view returns (address);

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Delegate calls to the provided target contract by forwarding the data. It then returns the data it
    /// gets back, bubbling up any potential revert.
    ///
    /// @dev Emits an {Execute} event.
    ///
    /// Requirements:
    /// - The caller must be either an owner or an envoy with permission.
    /// - `target` must be a deployed contract.
    /// - The gas stipend must be greater than or equal to `minGasReserve`.
    /// - The owner must not be changed during the DELEGATECALL.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return response The response received from the target contract.
    function execute(address target, bytes calldata data) external payable returns (bytes memory response);

    /// @notice Installs a plugin contract, which provides a method list.
    ///
    /// @dev Emits an {InstallPlugin} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    /// - The plugin must have at least one listed method.
    /// - By design, the plugin cannot implement any method that is also implemented by the proxy itself.
    ///
    /// Notes:
    /// - Does not revert if the plugin is already installed.
    /// - Installing a plugin is a potentially dangerous operation, because anyone can call the plugin's methods.
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

    /// @notice Transfers the owner of the contract to a new account.
    ///
    /// @dev Emits a {TransferOwnership} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newOwner The address of the new owner account.
    function transferOwnership(address newOwner) external;

    /// @notice Uninstalls a plugin contract, which provides a method list.
    ///
    /// @dev Emits an {UninstallPlugin} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    /// - The plugin must have at least one listed method.
    ///
    /// Notes:
    /// - Does not revert if the plugin is not already installed.
    ///
    /// @param plugin The address of the plugin to uninstall.
    function uninstallPlugin(IPRBProxyPlugin plugin) external;
}
