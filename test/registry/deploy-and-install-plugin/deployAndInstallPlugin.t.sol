// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndInstallPlugin_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deploy();
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_UserHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndInstallPlugin(plugins.basic);
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployAndInstallPlugin_ProxyAddress(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        address actualProxy = address(registry.deployAndInstallPlugin(plugins.basic));
        address expectedProxy = computeProxyAddress(owner);
        assertEq(actualProxy, expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployAndInstallPlugin_ProxyOwner(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy proxy = registry.deployAndInstallPlugin(plugins.basic);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployAndInstallPlugin_UpdateProxies(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        registry.deployAndInstallPlugin(plugins.basic);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(owner);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployAndInstallPlugin_Plugin(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        registry.deployAndInstallPlugin(plugins.basic);

        bytes4[] memory pluginMethods = plugins.basic.getMethods();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: owner, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.basic;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    function testFuzz_DeployAndInstallPlugin_PluginReverseMapping(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        registry.deployAndInstallPlugin(plugins.basic);

        bytes4[] memory actualMethods = registry.getMethodsByOwner({ owner: owner, plugin: plugins.basic });
        bytes4[] memory expectedMethods = plugins.basic.getMethods();
        assertEq(actualMethods, expectedMethods, "methods not saved in reverse mapping");
    }

    function testFuzz_DeployAndInstallPlugin_Event_DeployProxy(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: owner, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deployAndInstallPlugin(plugins.basic);
    }

    function testFuzz_DeployAndInstallPlugin_Event_InstallPlugin(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        vm.expectEmit({ emitter: address(registry) });
        emit InstallPlugin({
            owner: owner,
            proxy: IPRBProxy(computeProxyAddress(owner)),
            plugin: plugins.basic,
            methods: plugins.basic.getMethods()
        });
        registry.deployAndInstallPlugin(plugins.basic);
    }
}
