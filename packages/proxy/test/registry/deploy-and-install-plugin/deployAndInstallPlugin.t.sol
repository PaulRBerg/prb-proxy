// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

/// @dev User roles:
/// - Bob is the origin, operator, and owner of the proxy
contract DeployAndInstallPlugin_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deploy();
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deploy();
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

    function testFuzz_DeployAndInstallPlugin_PluginMethods() external whenOwnerDoesNotHaveProxy {
        registry.deployAndInstallPlugin(plugins.basic);
        bytes4[] memory pluginMethods = plugins.basic.getMethods();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.basic;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    function testFuzz_DeployAndInstallPlugin_ReverseMapping() external whenOwnerDoesNotHaveProxy {
        registry.deployAndInstallPlugin(plugins.basic);
        bytes4[] memory actualMethods = registry.getMethodsByOwner({ owner: users.alice, plugin: plugins.basic });
        bytes4[] memory expectedMethods = plugins.basic.getMethods();
        assertEq(actualMethods, expectedMethods, "methods not saved in reverse mapping");
    }

    function testFuzz_DeployAndInstallPlugin_Event(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: owner, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deploy();
    }
}
