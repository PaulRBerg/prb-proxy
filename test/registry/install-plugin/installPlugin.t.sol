// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract InstallPlugin_Test is Registry_Test {
    function test_RevertWhen_CallerDoesNotHaveProxy() external {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_CallerDoesNotHaveProxy.selector, users.bob)
        );
        changePrank({ msgSender: users.bob });
        registry.installPlugin(plugins.empty);
    }

    modifier whenCallerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    function test_RevertWhen_PluginEmptyMethodList() external whenCallerHasProxy {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_PluginEmptyMethodList.selector, plugins.empty)
        );
        registry.installPlugin(plugins.empty);
    }

    modifier whenPluginListNotEmpty() {
        _;
    }

    function test_InstallPlugin_PluginInstalledBefore()
        external
        whenCallerHasProxy
        whenPluginListNotEmpty
        whenPluginNotInstalled
    {
        // Install a dummy plugin that has some methods.
        registry.installPlugin(plugins.dummy);

        // Install the same plugin again.
        registry.installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    modifier whenPluginNotInstalled() {
        _;
    }

    function test_InstallPlugin() external whenCallerHasProxy whenPluginListNotEmpty whenPluginNotInstalled {
        // Install a dummy plugin that has some methods.
        registry.installPlugin(plugins.dummy);

        // Assert that every plugin method has been installed.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.dummy;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    function test_InstallPlugin_Event() external whenCallerHasProxy whenPluginListNotEmpty whenPluginNotInstalled {
        vm.expectEmit({ emitter: address(registry) });
        emit InstallPlugin({ owner: users.alice, proxy: proxy, plugin: plugins.dummy });
        registry.installPlugin(plugins.dummy);
    }
}
