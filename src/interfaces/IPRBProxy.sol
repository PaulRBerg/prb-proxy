// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxyPlugin } from "./IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "./IPRBProxyRegistry.sol";
import { IPRBProxyStorage } from "./IPRBProxyStorage.sol";

/// @title IPRBProxy
/// @notice Proxy contract to compose transactions on owner's behalf.
interface IPRBProxy is IPRBProxyStorage {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is not the registry.
    error PRBProxy_CallerNotRegistry(IPRBProxyRegistry registry, address caller);

    /// @notice Thrown when execution reverted with no reason.
    error PRBProxy_ExecutionReverted();

    /// @notice Thrown when the caller is not the owner.
    error PRBProxy_ExecutionUnauthorized(address owner, address caller, address target);

    /// @notice Thrown when the owner is changed during the DELEGATECALL.
    error PRBProxy_OwnerChanged(address originalOwner, address newOwner);

    /// @notice Thrown when a plugin execution reverts with no reason.
    error PRBProxy_PluginReverted(IPRBProxyPlugin plugin);

    /// @notice Thrown when the fallback function does not find an installed plugin for the called method.
    error PRBProxy_PluginNotInstalledForMethod(address caller, bytes4 selector);

    /// @notice Thrown when passing an EOA or an undeployed contract as the target.
    error PRBProxy_TargetNotContract(address target);

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the proxy executes a delegate call to a target contract.
    event Execute(address indexed target, bytes data, bytes response);

    /// @notice Emitted when a plugin is run for a provided method.
    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    /*//////////////////////////////////////////////////////////////////////////
                             PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the registry that has deployed this proxy.
    function registry() external view returns (IPRBProxyRegistry);

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

    /// @notice Transfers the owner of the contract to a new account.
    ///
    /// @dev Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newOwner The address of the new owner account.
    function transferOwnership(address newOwner) external;
}
