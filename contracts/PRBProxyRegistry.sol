// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";
import "./IPRBProxyRegistry.sol";

/// @title PRBProxyRegistry
/// @author Paul Razvan Berg
contract PRBProxyRegistry is IPRBProxyRegistry {
    /// @inheritdoc IPRBProxyRegistry
    mapping(address => mapping(bytes32 => IPRBProxy)) public override proxies;

    /// @inheritdoc IPRBProxyRegistry
    IPRBProxyFactory public override factory;

    /// CONSTRUCTOR ///

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyRegistry
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner) public override returns (address payable proxy) {
        bytes32 salt = bytes32(factory.salts(tx.origin));

        // Deploy the proxy via the factory.
        proxy = factory.deployFor(owner);

        // Save the proxy in the mapping.
        proxies[owner][salt] = IPRBProxy(proxy);
    }
}
