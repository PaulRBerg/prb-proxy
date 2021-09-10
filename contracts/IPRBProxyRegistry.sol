// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";

/// @title IPRBProxyRegistry
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances via the proxy factory and keeps a registry of owners to proxies.
interface IPRBProxyRegistry {
    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice Mapping of owner accounts to proxies.
    function proxies(address owner, bytes32 salt) external view returns (IPRBProxy);

    /// @notice Proxy factory contract.
    function factory() external view returns (IPRBProxyFactory);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy instance via the proxy factory.
    /// @dev Sets msg.sender as the owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy(bytes32 salt) external returns (address payable proxy);

    /// @notice Deploys a new proxy instance via the proxy factory, for a specific owner.
    /// @param owner The owner of the proxy.
    /// @param salt Random data used as an additional input to CREATE2.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner, bytes32 salt) external returns (address payable proxy);
}
