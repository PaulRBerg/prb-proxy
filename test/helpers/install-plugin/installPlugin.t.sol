// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyHelpers } from "src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { Helpers_Test } from "../Helpers.t.sol";

contract InstallPlugin_Test is Helpers_Test {
    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyHelpers.PRBProxy_NoPluginMethods.selector, plugins.empty));
        installPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should re-install the plugin.
    function test_InstallPlugin_PluginInstalledBefore() external pluginHasMethods pluginNotInstalled {
        // Install a dummy plugin that has some methods.
        installPlugin(plugins.dummy);

        // Install the same plugin again.
        installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.getPluginForMethod(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "Plugin method not installed");
        }
    }

    modifier pluginNotInstalled() {
        _;
    }

    /// @dev it should install the plugin.
    function test_InstallPlugin() external pluginHasMethods pluginNotInstalled {
        // Install a dummy plugin that has some methods.
        installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.getPluginForMethod(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "Plugin method not installed");
        }
    }

    /// @dev it should emit an {InstallPlugin} event.
    function test_InstallPlugin_Event() external pluginHasMethods pluginNotInstalled {
        // Expect an {InstallPlugin} event.
        expectEmit();
        emit InstallPlugin(plugins.dummy);

        // Install the dummy plugin.
        installPlugin(plugins.dummy);
    }
}
