// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyHelpers } from "src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { PluginDummy } from "../../shared/plugins/PluginDummy.t.sol";
import { PluginEmpty } from "../../shared/plugins/PluginEmpty.t.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract InstallPlugin_Test is Proxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address eve = users.eve;
        changePrank(eve);

        // Expect a {ExecutionUnauthorized} error because Bob is not the owner.
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, eve, targets.helpers)
        );
        installPlugin(plugins.dummy);
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_PluginHasNoMethods() external callerOwner {
        vm.expectRevert(abi.encodeWithSelector(IPRBProxyHelpers.PRBProxy_NoPluginMethods.selector, plugins.empty));
        installPlugin(plugins.empty);
    }

    modifier pluginHasMethods() {
        _;
    }

    /// @dev it should re-install the plugin.
    function test_InstallPlugin_PluginInstalledBefore() external callerOwner pluginHasMethods pluginNotInstalled {
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
    function test_InstallPlugin() external callerOwner pluginHasMethods pluginNotInstalled {
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
    function test_InstallPlugin_Event() external callerOwner pluginHasMethods pluginNotInstalled {
        // Expect an {InstallPlugin} event.
        expectEmit();
        emit InstallPlugin(plugins.dummy);

        // Install the dummy plugin.
        installPlugin(plugins.dummy);
    }
}
