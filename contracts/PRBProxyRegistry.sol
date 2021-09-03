// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxyRegistry.sol";
import "./PRBProxy.sol";
import "./PRBProxyFactory.sol";

/// @notice Emitted when a proxy has already been deployed.
error PRBProxyRegistry__ProxyAlreadyDeployed(address owner);

/// @title PRBProxyRegistry
/// @author Paul Razvan Berg
contract PRBProxyRegistry is IPRBProxyRegistry {
    /// @inheritdoc IPRBProxyRegistry
    mapping(address => PRBProxy) public override proxies;

    /// @inheritdoc IPRBProxyRegistry
    PRBProxyFactory public override factory;

    /// CONSTRUCTOR ///

    constructor(PRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyRegistry
    function deploy(bytes32 salt) external override returns (address payable proxy) {
        proxy = deployFor(msg.sender, salt);
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner, bytes32 salt) public override returns (address payable proxy) {
        // Do not deploy if the proxy already exists and the owner is the same.
        if (address(proxies[owner]) != address(0) && proxies[owner].owner() == owner) {
            revert PRBProxyRegistry__ProxyAlreadyDeployed(owner);
        }

        // Deploy the proxy via the factory.
        proxy = factory.deployFor(owner, salt);

        // Set the proxy in the mapping.
        proxies[owner] = PRBProxy(proxy);
    }
}
