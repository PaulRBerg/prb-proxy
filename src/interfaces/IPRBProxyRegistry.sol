// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./IPRBProxy.sol";

/// @title IPRBProxyRegistry
/// @notice Deploys new proxies with CREATE2 and keeps a registry of owners to proxies. Owners can only
/// have one proxy at a time.
interface IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when some function requires the owner to not have a proxy.
    error PRBProxyRegistry_OwnerHasProxy(address owner, IPRBProxy proxy);

    /// @notice Thrown when some function requires the owner to have a proxy.
    error PRBProxyRegistry_OwnerDoesNotHaveProxy(address owner);

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

    /// @notice Emitted when the owner transfers ownership of the proxy.
    event TransferOwnership(IPRBProxy proxy, address indexed oldOwner, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The semantic version of the {PRBProxy} release.
    /// @dev This is stored in the registry rather than the proxy to save gas for end users.
    function VERSION() external view returns (string memory);

    /// @notice Returns the next seed that will be used to deploy the proxy.
    /// @param origin The externally owned account (EOA) that is part of the CREATE2 salt.
    function getNextSeed(address origin) external view returns (bytes32 result);

    /// @notice Gets the current proxy of the provided owner.
    /// @param proxy The address of the current proxy.
    function getProxy(address owner) external view returns (IPRBProxy proxy);

    /// @notice Gets the owner to be used in constructing the proxy, set transiently during proxy deployment.
    /// @dev This is called by the proxy to fetch the address of the owner.
    /// @return owner The address of the owner of the proxy.
    function transientProxyOwner() external view returns (address owner);

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new proxy with CREATE2 by setting the caller as the owner.
    ///
    /// @dev Emits a {DeployProxy} event.
    ///
    /// Requirements:
    /// - The owner must not have a proxy.
    ///
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (IPRBProxy proxy);

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

    /// @notice Deploys a new proxy via CREATE@ by setting the caller as the owner, and delegate calls to the provided
    /// target contract by forwarding the data. It returns the data it gets back, bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - The owner must not have a proxy.
    /// - All from {PRBProxy-execute}.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy contract.
    /// @return response The response received from the target contract.
    function deployAndExecute(
        address target,
        bytes calldata data
    )
        external
        returns (IPRBProxy proxy, bytes memory response);

    /// @notice Deploys a new proxy with CREATE2 for the provided owner, and delegate calls to the provided target
    /// contract by forwarding the data. It returns the data it gets back, bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - The owner must not have a proxy.
    /// - All from {PRBProxy-execute}.
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
    )
        external
        returns (IPRBProxy proxy, bytes memory response);

    /// @notice Transfers the owner of the proxy to a new account.
    ///
    /// @dev Emits a {TransferOwnership} event.
    ///
    /// Requirements:
    /// - The caller must have a proxy.
    /// - The new owner must not have a proxy.
    ///
    /// @param newOwner The address of the new owner account.
    function transferOwnership(address newOwner) external;
}
