// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Registry_Test } from "../Registry.t.sol";

contract Deploy_Test is Registry_Test {
    address internal deployer;

    function setUp() public override {
        Registry_Test.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function test_Deploy() external {
        bytes memory actualRuntimeBytecode = address(registry.deploy()).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should update the current proxies mapping.
    function test_Deploy_UpdateCurrentProxies() external {
        registry.deploy();
        address actualProxyAddress = address(registry.getCurrentProxy(deployer));
        address expectedProxyAddress = computeProxyAddress(deployer, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address");
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_Deploy_Event() external {
        expectEmit();
        emit DeployProxy({
            origin: deployer,
            deployer: address(registry),
            owner: deployer,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(deployer, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(deployer, SEED_ZERO))
        });
        registry.deploy();
    }
}
