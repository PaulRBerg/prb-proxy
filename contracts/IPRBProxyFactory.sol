// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

/// @title IPRBProxyFactory
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances with CREATE2.
interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(address indexed deployer, address indexed owner, address proxy);

    /// PUBLIC CONSTANT FUNCTIONS ///

    function isProxy(address proxy) external returns (bool);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy instance with CREATE2.
    /// @dev Sets msg.sender as the owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy(bytes32 salt) external returns (address payable proxy);

    /// @notice Deploys a new proxy instance with CREATE2.
    /// @param owner The custom owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner, bytes32 salt) external returns (address payable proxy);
}
