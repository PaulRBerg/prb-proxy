// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract InstallPlugin_Test is Registry_Test {
    function test_RevertWhen_CallerDoesNotHaveProxy() external {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_UserDoesNotHaveProxy.selector, users.alice)
        );
        registry.installPlugin(plugins.empty);
    }

    modifier whenCallerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    function test_RevertWhen_PluginDoesNotImplementAnyMethod() external whenCallerHasProxy {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_PluginWithZeroMethods.selector, plugins.empty)
        );
        registry.installPlugin(plugins.empty);
    }

    modifier whenPluginImplementsMethods() {
        _;
    }

    function test_RevertWhen_PluginAlreadyInstalled()
        external
        whenCallerHasProxy
        whenPluginImplementsMethods
        whenPluginNotAlreadyInstalled
    {
        registry.installPlugin(plugins.basic);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxyRegistry.PRBProxyRegistry_PluginMethodCollision.selector,
                plugins.basic,
                plugins.basic,
                plugins.basic.foo.selector
            )
        );
        registry.installPlugin(plugins.basic);
    }

    modifier whenPluginNotAlreadyInstalled() {
        _;
    }

    function test_RevertWhen_MethodCollisions()
        external
        whenCallerHasProxy
        whenPluginImplementsMethods
        whenPluginNotAlreadyInstalled
    {
        registry.installPlugin(plugins.sablier);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxyRegistry.PRBProxyRegistry_PluginMethodCollision.selector,
                plugins.sablier,
                plugins.collider,
                plugins.sablier.onStreamCanceled.selector
            )
        );
        registry.installPlugin(plugins.collider);
    }

    modifier whenNoMethodCollisions() {
        _;
    }

    function test_InstallPlugin()
        external
        whenCallerHasProxy
        whenPluginImplementsMethods
        whenPluginNotAlreadyInstalled
        whenNoMethodCollisions
    {
        registry.installPlugin(plugins.basic);
        bytes4[] memory pluginMethods = plugins.basic.getMethods();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.basic;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    function test_InstallPlugin_ReverseMapping()
        external
        whenCallerHasProxy
        whenPluginImplementsMethods
        whenPluginNotAlreadyInstalled
        whenNoMethodCollisions
    {
        registry.installPlugin(plugins.basic);
        bytes4[] memory actualMethods = registry.getMethodsByOwner({ owner: users.alice, plugin: plugins.basic });
        bytes4[] memory expectedMethods = plugins.basic.getMethods();
        assertEq(actualMethods, expectedMethods, "methods not saved in reverse mapping");
    }

    function test_InstallPlugin_Event()
        external
        whenCallerHasProxy
        whenPluginImplementsMethods
        whenPluginNotAlreadyInstalled
        whenNoMethodCollisions
    {
        vm.expectEmit({ emitter: address(registry) });
        emit InstallPlugin({
            owner: users.alice,
            proxy: proxy,
            plugin: plugins.basic,
            methods: plugins.basic.getMethods()
        });
        registry.installPlugin(plugins.basic);
    }
}
