// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "./abstracts/PRBProxyStorage.sol";
import { IPRBProxyAnnex } from "./interfaces/IPRBProxyAnnex.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

 █████╗ ███╗   ██╗███╗   ██╗███████╗██╗  ██╗
██╔══██╗████╗  ██║████╗  ██║██╔════╝╚██╗██╔╝
███████║██╔██╗ ██║██╔██╗ ██║█████╗   ╚███╔╝
██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝   ██╔██╗
██║  ██║██║ ╚████║██║ ╚████║███████╗██╔╝ ██╗
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝

*/

/// @title PRBProxyAnnex
/// @dev See the documentation in {IPRBProxyAnnex}.
contract PRBProxyAnnex is
    IPRBProxyAnnex, // 0 inherited components
    PRBProxyStorage // 1 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyAnnex
    string public constant override VERSION = "4.0.0-beta.5";

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyAnnex
    function installPlugin(IPRBProxyPlugin plugin) external override {
        // Get the method list to install.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxy_NoPluginMethods(plugin);
        }

        // Enable every method in the list.
        for (uint256 i = 0; i < length;) {
            plugins[methodList[i]] = plugin;
            unchecked {
                i += 1;
            }
        }

        // Log the plugin installation.
        emit InstallPlugin(plugin);
    }

    /// @inheritdoc IPRBProxyAnnex
    function setPermission(address envoy, address target, bool permission) external override {
        permissions[envoy][target] = permission;
        emit SetPermission(envoy, target, permission);
    }

    /// @inheritdoc IPRBProxyAnnex
    function uninstallPlugin(IPRBProxyPlugin plugin) external {
        // Get the method list to uninstall.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxy_NoPluginMethods(plugin);
        }

        // Disable every method in the list.
        for (uint256 i = 0; i < length;) {
            delete plugins[methodList[i]];
            unchecked {
                i += 1;
            }
        }

        // Log the plugin uninstallation.
        emit UninstallPlugin(plugin);
    }
}
