// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndExecuteAndInstallPlugin_Test is Registry_Test {
    bytes internal data;
    uint256 internal input = 1729;
    address internal target;

    function setUp() public override {
        Registry_Test.setUp();

        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        target = address(targets.echo);
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deploy();
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_UserHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_ProxyAddress(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy actualProxy = registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
        address expectedProxy = computeProxyAddress(owner);
        assertEq(address(actualProxy), expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_ProxyOwner(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy proxy = registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_UpdateProxies(address owner)
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ msgSender: owner });
        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(owner);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_Plugin(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });

        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
        bytes4[] memory pluginMethods = plugins.basic.getMethods();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: owner, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = plugins.basic;
            assertEq(actualPlugin, expectedPlugin, "plugin method not installed");
        }
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_PluginReverseMapping(address owner)
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ msgSender: owner });

        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
        bytes4[] memory actualMethods = registry.getMethodsByOwner({ owner: owner, plugin: plugins.basic });
        bytes4[] memory expectedMethods = plugins.basic.getMethods();
        assertEq(actualMethods, expectedMethods, "methods not saved in reverse mapping");
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_Event_DeployProxy(address owner)
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ msgSender: owner });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: owner, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_Event_Execute(address owner)
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ msgSender: owner });

        vm.expectEmit({ emitter: computeProxyAddress(owner) });
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
    }

    function testFuzz_DeployAndExecuteAndInstallPlugin_Event_InstallPlugin(address owner)
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ msgSender: owner });

        vm.expectEmit({ emitter: address(registry) });
        emit InstallPlugin({
            owner: owner,
            proxy: IPRBProxy(computeProxyAddress(owner)),
            plugin: plugins.basic,
            methods: plugins.basic.getMethods()
        });
        registry.deployAndExecuteAndInstallPlugin(target, data, plugins.basic);
    }
}
