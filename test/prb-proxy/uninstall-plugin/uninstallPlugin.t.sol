// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { PluginDummy } from "../../helpers/plugins/PluginDummy.t.sol";
import { PluginEmpty } from "../../helpers/plugins/PluginEmpty.t.sol";

contract UninstallPlugin_Test is PRBProxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address eve = users.eve;
        changePrank(eve);

        // Should revert because Bob is not the owner.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, owner, eve));
        proxy.uninstallPlugin(plugins.dummy);
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external callerOwner {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NoPluginMethods.selector, plugins.empty));
        proxy.uninstallPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should do nothing.
    function test_UninstallPlugin_PluginNotInstalledBefore() external callerOwner pluginHasMethods {
        // Uninstall the plugin.
        proxy.uninstallPlugin(plugins.dummy);

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
        proxy.installPlugin(plugins.dummy);
        _;
    }

    /// @dev it should uninstall the plugin.
    function test_UninstallPlugin() external callerOwner pluginHasMethods pluginInstalled {
        // Uninstall the plugin.
        proxy.uninstallPlugin(plugins.dummy);

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
        vm.expectEmit({ checkTopic1: true, checkTopic2: false, checkTopic3: false, checkData: false });
        emit UninstallPlugin(plugins.dummy);

        // Uninstall the dummy plugin.
        proxy.uninstallPlugin(plugins.dummy);
    }
}
