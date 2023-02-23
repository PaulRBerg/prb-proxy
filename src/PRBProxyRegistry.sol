// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyFactory } from "./interfaces/IPRBProxyFactory.sol";
import { IPRBProxyRegistry } from "./interfaces/IPRBProxyRegistry.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

██████╗ ███████╗ ██████╗ ██╗███████╗████████╗██████╗ ██╗   ██╗
██╔══██╗██╔════╝██╔════╝ ██║██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝
██████╔╝█████╗  ██║  ███╗██║███████╗   ██║   ██████╔╝ ╚████╔╝
██╔══██╗██╔══╝  ██║   ██║██║╚════██║   ██║   ██╔══██╗  ╚██╔╝
██║  ██║███████╗╚██████╔╝██║███████║   ██║   ██║  ██║   ██║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝

 */

/// @title PRBProxyRegistry
/// @dev This contract implements the {IPRBProxyRegistry} interface.
contract PRBProxyRegistry is IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    IPRBProxyFactory public immutable override factory;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Internal mapping of owners to current proxies.
    mapping(address owner => IPRBProxy currentProxy) internal currentProxies;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Check that no proxy is currently registered for the owner.
    modifier noCurrentProxy(address owner) {
        IPRBProxy currentProxy = currentProxies[owner];
        if (address(currentProxy) != address(0) && currentProxy.owner() == owner) {
            revert PRBProxyRegistry_ProxyAlreadyExists(owner);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    function getCurrentProxy(address owner) external view override returns (IPRBProxy proxy) {
        proxy = currentProxies[owner];
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    function deploy() external override returns (IPRBProxy proxy) {
        proxy = deployFor({ owner: msg.sender });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner) public override noCurrentProxy(owner) returns (IPRBProxy proxy) {
        // Deploy the proxy via the factory.
        proxy = factory.deployFor(owner);

        // Set or override the current proxy for the owner.
        currentProxies[owner] = proxy;
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployAndExecute(
        address target,
        bytes calldata data
    ) external override returns (IPRBProxy proxy, bytes memory response) {
        (proxy, response) = deployAndExecuteFor({ owner: msg.sender, target: target, data: data });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployAndExecuteFor(
        address owner,
        address target,
        bytes calldata data
    ) public override noCurrentProxy(owner) returns (IPRBProxy proxy, bytes memory response) {
        // Deploy the proxy via the factory, and delegate call to the target.
        (proxy, response) = factory.deployAndExecuteFor(owner, target, data);

        // Set or override the current proxy for the owner.
        currentProxies[owner] = proxy;
    }
}
