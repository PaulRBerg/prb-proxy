// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "./interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "./PRBProxy.sol";

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
/// @dev See the documentation in {IPRBProxyRegistry}.
contract PRBProxyRegistry is IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    string public constant override VERSION = "4.0.0-beta.5";

    /*//////////////////////////////////////////////////////////////////////////
                                USER-FACING STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    ConstructorParams public override constructorParams;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    mapping(address owner => mapping(address envoy => mapping(address target => bool permission))) internal _permissions;

    mapping(address owner => mapping(bytes4 method => IPRBProxyPlugin plugin)) internal _plugins;

    mapping(address owner => IPRBProxy proxy) internal _proxies;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Check that the owner does not have a proxy.
    modifier noProxy(address owner) {
        IPRBProxy proxy = _proxies[owner];
        if (address(proxy) != address(0)) {
            revert PRBProxyRegistry_OwnerHasProxy(owner, proxy);
        }
        _;
    }

    /// @notice Checks that the caller has a proxy.
    modifier onlyCallerWithProxy() {
        if (address(_proxies[msg.sender]) == address(0)) {
            revert PRBProxyRegistry_CallerDoesNotHaveProxy(msg.sender);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    function getPermissionByOwner(
        address owner,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission)
    {
        permission = _permissions[owner][envoy][target];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getPermissionByProxy(
        IPRBProxy proxy,
        address envoy,
        address target
    )
        external
        view
        returns (bool permission)
    {
        permission = _permissions[proxy.owner()][envoy][target];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getPluginByOwner(address owner, bytes4 method) external view returns (IPRBProxyPlugin plugin) {
        plugin = _plugins[owner][method];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getPluginByProxy(IPRBProxy proxy, bytes4 method) external view returns (IPRBProxyPlugin plugin) {
        plugin = _plugins[proxy.owner()][method];
    }

    /// @inheritdoc IPRBProxyRegistry
    function getProxy(address owner) external view returns (IPRBProxy proxy) {
        proxy = _proxies[owner];
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    function deploy() external override noProxy(msg.sender) returns (IPRBProxy proxy) {
        proxy = _deploy({ owner: msg.sender });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployAndExecute(
        address target,
        bytes calldata data
    )
        external
        override
        noProxy(msg.sender)
        returns (IPRBProxy proxy)
    {
        // Use the address of the owner as the CREATE2 salt.
        address owner = msg.sender;
        bytes32 salt = bytes32(abi.encodePacked(owner));

        // Deploy the proxy with CREATE2, and execute the delegate call in the constructor.
        constructorParams = ConstructorParams({ owner: owner, target: target, data: data });
        proxy = new PRBProxy{ salt: salt }();
        delete constructorParams;

        // Associate the owner and the proxy.
        _proxies[owner] = proxy;

        // Log the creation of the proxy.
        emit DeployProxy({ operator: msg.sender, owner: owner, proxy: proxy });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner) public override noProxy(owner) returns (IPRBProxy proxy) {
        proxy = _deploy(owner);
    }

    /// @inheritdoc IPRBProxyRegistry
    function installPlugin(IPRBProxyPlugin plugin) external override onlyCallerWithProxy {
        // Get the method list to install.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxyRegistry_PluginEmptyMethodList(plugin);
        }

        // Install every method in the list.
        address owner = msg.sender;
        for (uint256 i = 0; i < length;) {
            // Check for collisions.
            bytes4 method = methodList[i];
            if (address(_plugins[owner][method]) != address(0)) {
                revert PRBProxyRegistry_PluginMethodCollision({
                    currentPlugin: _plugins[owner][method],
                    newPlugin: plugin,
                    method: method
                });
            }
            _plugins[owner][method] = plugin;
            unchecked {
                i += 1;
            }
        }

        // Log the plugin installation.
        emit InstallPlugin(owner, _proxies[owner], plugin);
    }

    /// @inheritdoc IPRBProxyRegistry
    function setPermission(address envoy, address target, bool permission) external override onlyCallerWithProxy {
        address owner = msg.sender;
        _permissions[owner][envoy][target] = permission;
        emit SetPermission(owner, _proxies[owner], envoy, target, permission);
    }

    /// @inheritdoc IPRBProxyRegistry
    function uninstallPlugin(IPRBProxyPlugin plugin) external override onlyCallerWithProxy {
        // Get the method list to uninstall.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxyRegistry_PluginEmptyMethodList(plugin);
        }

        // Uninstall every method in the list.
        address owner = msg.sender;
        for (uint256 i = 0; i < length;) {
            delete _plugins[owner][methodList[i]];
            unchecked {
                i += 1;
            }
        }

        // Log the plugin uninstallation.
        emit UninstallPlugin(owner, _proxies[owner], plugin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _deploy(address owner) internal returns (IPRBProxy proxy) {
        // Use the address of the owner as the CREATE2 salt.
        bytes32 salt = bytes32(abi.encodePacked(owner));

        // Set the owner and empty out the target and the data to prevent reentrancy.
        constructorParams = ConstructorParams({ owner: owner, target: address(0), data: "" });

        // Deploy the proxy with CREATE2.
        proxy = new PRBProxy{ salt: salt }();
        delete constructorParams;

        // Associate the owner and the proxy.
        _proxies[owner] = proxy;

        // Log the creation of the proxy.
        emit DeployProxy({ operator: msg.sender, owner: owner, proxy: proxy });
    }
}
