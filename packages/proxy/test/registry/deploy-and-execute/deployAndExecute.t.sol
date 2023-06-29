// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndExecute_Test is Registry_Test {
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
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndExecute(target, data);
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployAndExecute_ProxyAddress(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy actualProxy = registry.deployAndExecute(target, data);
        address expectedProxy = computeProxyAddress(owner);
        assertEq(address(actualProxy), expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployAndExecute_ProxyOwner(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy proxy = registry.deployAndExecute(target, data);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployAndExecute_UpdateProxies(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        registry.deployAndExecute(target, data);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(owner);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployAndExecute_Event_DeployProxy(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: owner, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deployAndExecute(target, data);
    }

    function testFuzz_DeployAndExecute_Event_Execute(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });

        vm.expectEmit({ emitter: computeProxyAddress(owner) });
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecute(target, data);
    }
}
