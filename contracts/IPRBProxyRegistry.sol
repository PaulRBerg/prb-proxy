// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./PRBProxy.sol";
import "./PRBProxyFactory.sol";

/// @title IPRBProxyRegistry
/// @author Paul Razvan Berg
/// @notice Deploys new proxy instances via the proxy factory and keeps a registry of owners to proxies.
interface IPRBProxyRegistry {
    /// CONSTANT FUNCTIONS ///

    /// @notice Mapping of owner accounts to proxies.
    function proxies(address owner) external view returns (PRBProxy);

    /// @notice Proxy factory contract.
    function factory() external view returns (PRBProxyFactory);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Deploys a new proxy instance via the proxy factory.
    /// @dev Sets msg.sender as the owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deploy() external returns (address payable proxy);

    /// @notice Deploys a new proxy instance via the proxy factory.
    /// @param owner The custom owner of the proxy.
    /// @return proxy The address of the newly deployed proxy contract.
    function deployFor(address owner) external returns (address payable proxy);
}
