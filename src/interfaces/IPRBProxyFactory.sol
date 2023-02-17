// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./IPRBProxy.sol";

/// @title IPRBProxyFactory
/// @author Paul Razvan Berg
/// @notice Deploys new proxies with CREATE2.
interface IPRBProxyFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new proxy is deployed.
    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        IPRBProxy proxy
    );

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Gets the next seed that will be used to deploy the proxy.
    /// @param eoa The externally owned account that will own the proxy.
    function getNextSeed(address eoa) external view returns (bytes32 result);

    /// @notice Checks if the given address is a deployed proxy.
    /// @param proxy The address of the proxy to make the query for.
    function isProxy(IPRBProxy proxy) external view returns (bool result);

    /// @notice The release version of {PRBProxy}.
    /// @dev This is stored in the factory rather than the proxy to save gas for end users.
    function version() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new proxy with CREATE2 by setting the caller as the owner.
    /// @dev Emits a {DeployProxy} event.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy with CREATE2 for the given owner.
    /// @dev Emits a {DeployProxy} event.
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (IPRBProxy proxy);

    /// @notice Deploys a new proxy with CREATE2 by setting the caller as the owner, and delegate calls to the
    /// given target contract by forwarding the data. It returns the data it gets back, bubbling up any potential
    /// revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
    /// - All from {PRBProxy-execute}.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return proxy The address of the newly deployed proxy contract.
    /// @return response The response received from the target contract.
    function deployAndExecute(
        address target,
        bytes calldata data
    ) external returns (IPRBProxy proxy, bytes memory response);

    /// @notice Deploys a new proxy with CREATE2 for the given owner, and delegate calls to the given target
    /// contract by forwarding the data. It returns the data it gets back, bubbling up any potential revert.
    ///
    /// @dev Emits a {DeployProxy} and an {Execute} event.
    ///
    /// Requirements:
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
    ) external returns (IPRBProxy proxy, bytes memory response);
}
