// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyAnnex } from "src/interfaces/IPRBProxyAnnex.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { Annex_Test } from "../Annex.t.sol";

contract UninstallPlugin_Test is Annex_Test {
    function test_RevertWhen_PluginHasNoMethods() external {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyAnnex.PRBProxy_NoPluginMethods.selector, plugins.empty));
        uninstallPlugin(plugins.empty);
    }

    modifier whenPluginHasMethods() {
        _;
    }

    function test_UninstallPlugin_PluginNotInstalledBefore() external whenPluginHasMethods {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "plugin method still installed");
        }
    }

    modifier whenPluginInstalled() {
        // Install the dummy plugin.
        installPlugin(plugins.dummy);
        _;
    }

    function test_UninstallPlugin() external whenPluginHasMethods whenPluginInstalled {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "plugin method still installed");
        }
    }

    function test_UninstallPlugin_Event() external whenPluginHasMethods whenPluginInstalled {
        // Expect an {UninstallPlugin} event to be emitted.
        vm.expectEmit({ emitter: address(proxy) });
        emit UninstallPlugin(plugins.dummy);

        // Uninstall the dummy plugin.
        uninstallPlugin(plugins.dummy);
    }
}
