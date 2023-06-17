// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./IPRBProxy.sol";
import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";

/// @title IPRBProxyRegistry
/// @notice Deploys new proxies with CREATE2 and keeps a registry of owners to proxies. Owners can only
/// have only one proxy at a time.
interface IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when an action requires the caller to have a proxy.
    error PRBProxyRegistry_CallerDoesNotHaveProxy(address caller);

    /// @notice Thrown when an action requires the owner to not have a proxy.
    error PRBProxyRegistry_OwnerHasProxy(address owner, IPRBProxy proxy);

    /// @notice Thrown when installing or uninstall a plugin, and the plugin doesn't implement any method.
    error PRBProxyRegistry_PluginEmptyMethodList(IPRBProxyPlugin plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new proxy is deployed.
    event DeployProxy(
        address indexed origin,
        address indexed operator,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        IPRBProxy proxy
    );

    /// @notice Emitted when a plugin is installed.
    event InstallPlugin(address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin);

    /// @notice Emitted when an envoy permission is updated.
    event SetPermission(
        address indexed owner, IPRBProxy indexed proxy, address indexed envoy, address target, bool permission
    );

    /// @notice Emitted when a plugin is uninstalled.
    event UninstallPlugin(address indexed owner, IPRBProxy indexed proxy, IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                      STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @param owner The address of the user who will own the proxy.
    /// @param target The address of the target contract to delegate call to. Can be set to zero.
    /// @param data The address of the call data to pass to the target contract. Can be set to zero.
    struct ConstructorParams {
        address owner;
        address target;
        bytes data;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The release version of the proxy system, which applies to both the registry and deployed proxies.
    /// @dev This is stored in the registry rather than the proxy to save gas for end users.
    function VERSION() external view returns (string memory);

    /// @notice The parameters used in constructing the proxy, which the registry sets transiently during proxy
    /// deployment.
    /// @dev The proxy constructor fetches these parameters.
    function constructorParams() external view returns (address owner, address target, bytes memory data);

    /// @notice Retrieves a boolean flag that indicates whether the provided envoy has permission to call the provided
    /// target contract.
    /// @param owner The proxy owner to make the query for.
    /// @param envoy The address with permission to call the target contract.
    /// @param target The address of the target contract.
    function getPermissionByOwner(
        address owner,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission);

    /// @notice Retrieves a boolean flag that indicates whether the provided envoy has permission to call the provided
    /// target contract.
    /// @param proxy The proxy contract to make the query for.
    /// @param envoy The address with permission to call the target contract.
    /// @param target The address of the target contract.
    function getPermissionByProxy(
        IPRBProxy proxy,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission);

    /// @notice Retrieves the address of the plugin contract installed for the provided method selector.
    /// @dev The zero address is returned if no plugin contract is installed.
    /// @param owner The proxy owner to make the query for.
    /// @param method The method's signature for the query.
    function getPluginByOwner(address owner, bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice Retrieves the address of the plugin contract installed for the provided method selector.
    /// @dev The zero address is returned if no plugin contract is installed.
    /// @param proxy The proxy contract to make the query for.
    /// @param method The method's signature for the query.
    function getPluginByProxy(IPRBProxy proxy, bytes4 method) external view returns (IPRBProxyPlugin plugin);

    /// @notice Retrieves the proxy for the provided owner.
    /// @param owner The user address to make the query for.
    function getProxy(address owner) external view returns (IPRBProxy proxy);

    /// @notice The seed that will be used to deploy the next proxy for the provided origin.
    /// @param origin The externally owned account (EOA) that is part of the CREATE2 salt.
    function nextSeeds(address origin) external view returns (bytes32 seed);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new proxy with CREATE2 by setting the caller as the owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    ///
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy via CREATE2 by setting the caller as the owner, and delegate calls to the provided
    /// target contract by forwarding the data. It returns the data it gets back, bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - The caller must not have a proxy.
    /// - All from {PRBProxy.execute}.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployAndExecute(address target, bytes calldata data) external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy with CREATE2 for the provided owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The owner must not have a proxy.
    ///
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (IPRBProxy proxy);

    /// @notice Installs the provided plugin contract on the proxy belonging to the caller.
    ///
    /// @dev Emits an {InstallPlugin} event.
    ///
    /// Notes:
    /// - Does not revert if the plugin is installed.
    /// - Installing a plugin is a potentially dangerous operation, because anyone will be able to run the plugin.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    /// - The plugin must have at least one implemented method.
    /// - By design, the plugin cannot implement any method that is also implemented by the proxy itself.
    ///
    /// @param plugin The address of the plugin to install.
    function installPlugin(IPRBProxyPlugin plugin) external;

    /// @notice Gives or takes a permission from an envoy to call the provided target contract and function selector
    /// on behalf of the proxy belonging to the caller.
    ///
    /// @dev Emits a {SetPermission} event.
    ///
    /// Notes:
    /// - It is not an error to set the same permission.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    ///
    /// @param envoy The address of the envoy account.
    /// @param target The address of the target contract.
    /// @param permission The boolean permission to set.
    function setPermission(address envoy, address target, bool permission) external;

    /// @notice Uninstalls the provided plugin contract from the proxy belonging to the caller.
    ///
    /// @dev Emits an {UninstallPlugin} event.
    ///
    /// Notes:
    /// - Does not revert if the plugin is not installed.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    /// - The plugin must have at least one implemented method.
    ///
    /// @param plugin The address of the plugin to uninstall.
    function uninstallPlugin(IPRBProxyPlugin plugin) external;
}
