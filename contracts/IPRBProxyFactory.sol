// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";

/// @title IPRBProxyFactory
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances with CREATE2.
interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(address indexed deployer, address indexed owner, address proxy);

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice The address of the implementation of PRBProxy, deployed once per chain.
    function implementation() external view returns (IPRBProxy);

    /// @notice Mapping to track all deployed proxies.
    function isProxy(address proxy) external view returns (bool);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy as an EIP-1167 clone deployed via CREATE2.
    /// @dev Sets msg.sender as the owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy(bytes32 salt) external returns (address payable proxy);

    /// @notice Deploys a new proxy as an EIP-1167 clone deployed via CREATE2, for a specific owner.
    /// @param owner The owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner, bytes32 salt) external returns (address payable proxy);
}
