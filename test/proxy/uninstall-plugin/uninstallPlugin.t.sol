// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyHelpers } from "src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { PluginDummy } from "../../shared/plugins/PluginDummy.t.sol";
import { PluginEmpty } from "../../shared/plugins/PluginEmpty.t.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract UninstallPlugin_Test is Proxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address eve = users.eve;
        changePrank(eve);

        // Expect a {ExecutionUnauthorized} error because Bob is not the owner.
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, eve, targets.helpers)
        );
        uninstallPlugin(plugins.dummy);
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external callerOwner {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyHelpers.PRBProxy_NoPluginMethods.selector, plugins.empty));
        uninstallPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should do nothing.
    function test_UninstallPlugin_PluginNotInstalledBefore() external callerOwner pluginHasMethods {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.getPluginForMethod(pluginMethods[i]);
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
    function test_UninstallPlugin() external callerOwner pluginHasMethods pluginInstalled {
        // Uninstall the plugin.
        uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.getPluginForMethod(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "Plugin method installed");
        }
    }

    /// @dev it should emit an {UninstallPlugin} event.
    function test_UninstallPlugin_Event() external callerOwner pluginHasMethods pluginInstalled {
        // Expect an {UninstallPlugin} event to be emitted.
        expectEmit();
        emit UninstallPlugin(plugins.dummy);

        // Uninstall the dummy plugin.
        uninstallPlugin(plugins.dummy);
    }
}
