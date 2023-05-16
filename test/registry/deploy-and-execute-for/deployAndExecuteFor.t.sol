// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndExecuteFor_Test is Registry_Test {
    bytes internal data;
    uint256 internal input = 1729;
    address internal target;

    function setUp() public override {
        Registry_Test.setUp();

        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        target = address(targets.echo);
    }

    function test_RevertWhen_OwnerHasProxy() external {
        (IPRBProxy proxy,) = registry.deployAndExecuteFor({ owner: users.alice, target: target, data: data });
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndExecuteFor({ owner: users.alice, target: target, data: data });
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployAndExecuteFor_Deploy(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        (IPRBProxy actualProxy,) = registry.deployAndExecuteFor(owner, target, data);
        address expectedProxy = computeProxyAddress(origin, SEED_ZERO);
        assertEq(address(actualProxy), expectedProxy, "deployed proxy address");
    }

    function testFuzz_DeployAndExecuteFor_UpdateNextSeeds(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployAndExecuteFor(owner, target, data);

        bytes32 actualNextSeed = registry.nextSeeds(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed");
    }

    function testFuzz_DeployAndExecuteFor_UpdateCurrentProxies(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployAndExecuteFor(owner, target, data);

        address actualProxyAddress = address(registry.proxies(owner));
        address expectedProxyAddress = computeProxyAddress(origin, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address");
    }

    function testFuzz_DeployAndExecuteFor_Execute(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        (, bytes memory actualResponse) = registry.deployAndExecuteFor(owner, target, data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response");
    }

    function testFuzz_DeployAndExecuteFor_Event_Deploy(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({
            origin: origin,
            operator: operator,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(origin, SEED_ZERO))
        });
        registry.deployAndExecuteFor(owner, target, data);
    }

    function testFuzz_DeployAndExecuteFor_Event_Execute(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        vm.expectEmit({ emitter: computeProxyAddress({ origin: origin, seed: SEED_ZERO }) });
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecuteFor(owner, target, data);
    }
}
