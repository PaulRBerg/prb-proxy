// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyAnnex } from "src/interfaces/IPRBProxyAnnex.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { Annex_Test } from "../Annex.t.sol";

contract InstallPlugin_Test is Annex_Test {
    function test_RevertWhen_PluginHasNoMethods() external {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyAnnex.PRBProxy_NoPluginMethods.selector, plugins.empty));
        installPlugin(plugins.empty);
    }

    modifier whenPluginHasMethods() {
        _;
    }

    function test_InstallPlugin_PluginInstalledBefore() external whenPluginHasMethods whenPluginNotInstalled {
        // Install a dummy plugin that has some methods.
        installPlugin(plugins.dummy);

        // Install the same plugin again.
        installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "Plugin method not installed");
        }
    }

    modifier whenPluginNotInstalled() {
        _;
    }

    function test_InstallPlugin() external whenPluginHasMethods whenPluginNotInstalled {
        // Install a dummy plugin that has some methods.
        installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.plugins(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "Plugin method not installed");
        }
    }

    function test_InstallPlugin_Event() external whenPluginHasMethods whenPluginNotInstalled {
        // Expect an {InstallPlugin} event.
        vm.expectEmit({ emitter: address(proxy) });
        emit InstallPlugin(plugins.dummy);

        // Install the dummy plugin.
        installPlugin(plugins.dummy);
    }
}
