// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract UninstallPlugin_Test is Registry_Test {
    function test_RevertWhen_CallerDoesNotHaveProxy() external {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_CallerDoesNotHaveProxy.selector, users.bob)
        );
        changePrank({ msgSender: users.bob });
        registry.uninstallPlugin(plugins.empty);
    }

    modifier whenCallerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    function test_RevertWhen_PluginUnknown() external whenCallerHasProxy {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_PluginUnknown.selector, plugins.empty)
        );
        registry.uninstallPlugin(plugins.empty);
    }

    modifier whenPluginKnown() {
        registry.installPlugin(plugins.basic);
        _;
    }

    function test_UninstallPlugin() external whenCallerHasProxy whenPluginKnown {
        // Uninstall the plugin.
        registry.uninstallPlugin(plugins.basic);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.basic.getMethods();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "plugin method still installed");
        }
    }

    function test_UninstallPlugin_ReverseMapping() external whenCallerHasProxy whenPluginKnown {
        registry.uninstallPlugin(plugins.basic);
        bytes4[] memory actualMethods = registry.getMethodsByOwner({ owner: users.alice, plugin: plugins.basic });
        bytes4[] memory expectedMethods;
        assertEq(actualMethods, expectedMethods, "methods not removed from reverse mapping");
    }

    function test_UninstallPlugin_Event() external whenCallerHasProxy whenPluginKnown {
        vm.expectEmit({ emitter: address(registry) });
        emit UninstallPlugin({
            owner: users.alice,
            proxy: proxy,
            plugin: plugins.basic,
            methods: plugins.basic.getMethods()
        });
        registry.uninstallPlugin(plugins.basic);
    }
}
