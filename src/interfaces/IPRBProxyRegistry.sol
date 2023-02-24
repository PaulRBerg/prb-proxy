// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./IPRBProxy.sol";
import { IPRBProxyFactory } from "./IPRBProxyFactory.sol";

/// @title IPRBProxyRegistry
/// @notice Deploys new proxies via the factory and keeps a registry of owners to proxies. Owners can only
/// have one proxy at a time.
interface IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a proxy already exists for the provided owner.
    error PRBProxyRegistry_ProxyAlreadyExists(address owner);

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Address of the proxy factory contract.
    function factory() external view returns (IPRBProxyFactory proxyFactory);

    /// @notice Gets the current proxy of the provided owner.
    /// @param owner The address of the owner of the current proxy.
    function getCurrentProxy(address owner) external view returns (IPRBProxy proxy);

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new proxy via the proxy factory by setting the caller as the owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - All from {deployFor}.
    ///
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy via the proxy factory for the provided owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The proxy must either not exist or its ownership must have been transferred by the owner.
    ///
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy via the proxy factory by setting the caller as the owner, and delegate calls to the
    /// provided target contract by forwarding the data. It returns the data it gets back, bubbling up any potential
    /// revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - All from {PRBProxyFactory-deployAndExecute}.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy contract.
    /// @return response The response received from the target contract.
    function deployAndExecute(
        address target,
        bytes calldata data
    ) external returns (IPRBProxy proxy, bytes memory response);

    /// @notice Deploys a new proxy via the proxy factor for the provided owner, and delegate calls to the provided
    /// target contract by forwarding the data. It returns the data it gets back, bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - The proxy must either not exist or its ownership must have been transferred by the owner.
    /// - All from {PRBProxyFactory-deployAndExecuteFor}.
    ///
    /// @param owner The owner of the proxy.
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy contract.
    /// @return response The response received from the target contract.
    function deployAndExecuteFor(
        address owner,
        address target,
        bytes calldata data
    ) external returns (IPRBProxy proxy, bytes memory response);
}
