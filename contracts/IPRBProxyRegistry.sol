// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";

/// @title IPRBProxyRegistry
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances via the proxy factory and keeps a registry of owners to proxies.
interface IPRBProxyRegistry {
    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice Mapping of owners to salts to proxies.
    function proxies(address owner, bytes32 salt) external view returns (IPRBProxy proxy);

    /// @notice Proxy factory contract.
    function factory() external view returns (IPRBProxyFactory proxyFactory);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy instance via the proxy factory.
    /// @dev Sets "msg.sender" as the owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (address payable proxy);

    /// @notice Deploys a new proxy instance via the proxy factory, for a specific owner.
    /// @param owner The owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (address payable proxy);
}
