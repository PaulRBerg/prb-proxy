// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Factory_Test } from "../Factory.t.sol";

contract DeployAndExecuteFor_Test is Factory_Test {
    bytes internal data;
    address internal deployer;
    uint256 internal input = 1729;
    address internal owner;
    address internal target;

    function setUp() public override {
        Factory_Test.setUp();

        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        deployer = users.alice;
        owner = users.bob;
        target = address(targets.echo);
    }

    /// @dev it should deploy the proxy.
    function test_DeployAndExecuteFor_Deploy() external {
        (IPRBProxy proxy, ) = factory.deployAndExecuteFor(owner, target, data);
        bytes memory actualRuntimeBytecode = address(proxy).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should delegate call to the target contract.
    function test_DeployAndExecuteFor_Execute() external {
        (, bytes memory actualResponse) = factory.deployAndExecute(target, data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response");
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_DeployAndExecuteFor_Event_Deploy() external {
        expectEmit();
        emit DeployProxy({
            origin: deployer,
            deployer: deployer,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(deployer, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(deployer, SEED_ZERO))
        });
        factory.deployAndExecuteFor(owner, target, data);
    }

    /// @dev it should emit an {Execute} event.
    function test_DeployAndExecuteFor_Event_Execute() external {
        expectEmit();
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        factory.deployAndExecuteFor(owner, target, data);
    }
}
