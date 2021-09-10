// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";

/// @title IPRBProxyFactory
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances with CREATE2.
interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(address indexed origin, address indexed deployer, address indexed owner, address proxy);

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice The address of the implementation of PRBProxy.
    function implementation() external view returns (IPRBProxy proxy);

    /// @notice Mapping to track all deployed proxies.
    function isProxy(address proxy) external view returns (bool result);

    /// @notice Mapping to track used salts per EOA.
    function salts(address eoa) external view returns (bytes32 salt);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy as an EIP-1167 clone deployed via CREATE2.
    /// @dev Sets "msg.sender" as the owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (address payable proxy);

    /// @notice Deploys a new proxy as an EIP-1167 clone deployed via CREATE2, for a specific owner.
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (address payable proxy);
}
