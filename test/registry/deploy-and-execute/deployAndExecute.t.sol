// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndExecute_Test is Registry_Test {
    bytes internal data;
    address internal deployer;
    uint256 internal input = 1729;
    address internal target;

    function setUp() public override {
        Registry_Test.setUp();
        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        deployer = users.alice;
        target = address(targets.echo);
    }

    /// @dev it should deploy the proxy.
    function test_DeployAndExecute_Deploy() external {
        (IPRBProxy proxy, ) = registry.deployAndExecute(target, data);
        bytes memory actualRuntimeBytecode = address(proxy).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should update the current proxies mapping.
    function test_DeployAndExecute_UpdateCurrentProxies() external {
        registry.deployAndExecute(target, data);
        address actualProxyAddress = address(registry.getCurrentProxy(deployer));
        address expectedProxyAddress = computeProxyAddress(deployer, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address");
    }

    /// @dev it should delegate call to the target contract.
    function test_DeployAndExecute_Execute() external {
        (, bytes memory actualResponse) = registry.deployAndExecute(target, data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response");
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_DeployAndExecute_Event_Deploy() external {
        expectEmit();
        emit DeployProxy({
            origin: deployer,
            deployer: address(registry),
            owner: deployer,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(deployer, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(deployer, SEED_ZERO))
        });
        registry.deployAndExecute(target, data);
    }

    /// @dev it should emit an {Execute} event.
    function test_DeployAndExecute_Event_Execute() external {
        expectEmit();
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecute(target, data);
    }
}
