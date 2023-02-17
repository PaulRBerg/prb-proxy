// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { PluginDummy } from "../../helpers/plugins/PluginDummy.t.sol";
import { PluginEmpty } from "../../helpers/plugins/PluginEmpty.t.sol";

contract InstallPlugin_Test is PRBProxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address eve = users.eve;
        changePrank(eve);

        // Should revert because Bob is not the owner.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, owner, eve));
        proxy.installPlugin(plugins.dummy);
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external callerOwner {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NoPluginMethods.selector, plugins.empty));
        proxy.installPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should re-install the plugin.
    function test_InstallPlugin_PluginInstalledBefore() external callerOwner pluginHasMethods pluginNotInstalled {
        // Install a dummy plugin that has some methods.
        proxy.installPlugin(plugins.dummy);

        // Install the same plugin again.
        proxy.installPlugin(plugins.dummy);

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
    function test_InstallPlugin() external callerOwner pluginHasMethods pluginNotInstalled {
        // Install a dummy plugin that has some methods.
        proxy.installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = proxy.getPluginForMethod(pluginMethods[i]);
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "PLugin method not installed");
        }
    }

    /// @dev it should emit an {InstallPlugin} event.
    function test_InstallPlugin_Event() external callerOwner pluginHasMethods pluginNotInstalled {
        // Check install event is emitted
        vm.expectEmit({ checkTopic1: true, checkTopic2: false, checkTopic3: false, checkData: false });
        emit InstallPlugin(plugins.dummy);

        // Install the dummy plugin.
        proxy.installPlugin(plugins.dummy);
    }
}
