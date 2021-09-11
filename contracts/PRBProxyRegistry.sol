// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";
import "./IPRBProxyRegistry.sol";

/// @notice Emitted when a proxy already exists for the given owner.
error PRBProxyRegistry__ProxyAlreadyExists(address owner);

/// @title PRBProxyRegistry
/// @author Paul Razvan Berg
contract PRBProxyRegistry is IPRBProxyRegistry {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxyRegistry
    IPRBProxyFactory public override factory;

    /// INTERNAL STORAGE ///

    /// @notice Internal mapping of owners to salts to proxies.
    mapping(address => mapping(bytes32 => IPRBProxy)) internal proxies;

    /// @dev Internal mapping to track the last used by an EOA.
    mapping(address => bytes32) internal lastSalts;

    /// CONSTRUCTOR ///

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyRegistry
    function getLastProxy(address owner) public view override returns (IPRBProxy proxy) {
        bytes32 lastSalt = lastSalts[owner];
        proxy = proxies[owner][lastSalt];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getLastSalt(address owner) external view override returns (bytes32 lastSalt) {
        lastSalt = lastSalts[owner];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getProxy(address owner, bytes32 salt) external view override returns (IPRBProxy proxy) {
        proxy = proxies[owner][salt];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyRegistry
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner) public override returns (address payable proxy) {
        IPRBProxy lastProxy = getLastProxy(owner);

        // Do not deploy if the proxy already exists and the owner is the same.
        if (address(lastProxy) != address(0) && lastProxy.owner() == owner) {
            revert PRBProxyRegistry__ProxyAlreadyExists(owner);
        }
        bytes32 salt = bytes32(factory.getNextSalt(tx.origin));

        // Deploy the proxy via the factory.
        proxy = factory.deployFor(owner);

        // Save the proxy in the mapping.
        proxies[owner][salt] = IPRBProxy(proxy);

        // Save the last salt.
        lastSalts[owner] = salt;
    }
}
