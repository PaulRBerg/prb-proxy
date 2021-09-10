// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";
import "./IPRBProxyRegistry.sol";

/// @title PRBProxyRegistry
/// @author Paul Razvan Berg
contract PRBProxyRegistry is IPRBProxyRegistry {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxyRegistry
    IPRBProxyFactory public override factory;

    /// INTERNAL STORAGE ///

    /// @notice Internal mapping of owners to salts to proxies.
    mapping(address => mapping(bytes32 => IPRBProxy)) internal _proxies;

    /// CONSTRUCTOR ///

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyRegistry
    function proxies(address owner, bytes32 salt) external view override returns (IPRBProxy proxy) {
        proxy = _proxies[owner][salt];
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
        _proxies[owner][salt] = IPRBProxy(proxy);
    }
}
