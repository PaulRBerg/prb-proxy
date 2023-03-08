// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyHelpers } from "src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { Helpers_Test } from "../Helpers.t.sol";

contract UninstallPlugin_Test is Helpers_Test {
    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyHelpers.PRBProxy_NoPluginMethods.selector, plugins.empty));
        uninstallPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should do nothing.
    function test_UninstallPlugin_PluginNotInstalledBefore() external pluginHasMethods {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "Plugin method installed");
        }
    }

    modifier pluginInstalled() {
        // Install the dummy plugin.
        installPlugin(plugins.dummy);
        _;
    }

    /// @dev it should uninstall the plugin.
    function test_UninstallPlugin() external pluginHasMethods pluginInstalled {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "Plugin method installed");
        }
    }

    /// @dev it should emit an {UninstallPlugin} event.
    function test_UninstallPlugin_Event() external pluginHasMethods pluginInstalled {
        // Expect an {UninstallPlugin} event to be emitted.
        expectEmit();
        emit UninstallPlugin(plugins.dummy);

        // Uninstall the dummy plugin.
        uninstallPlugin(plugins.dummy);
    }
}
