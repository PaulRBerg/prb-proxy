// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { PRBProxyFactory_Test } from "../PRBProxyFactory.t.sol";

contract Deploy_Test is PRBProxyFactory_Test {
    address internal deployer;

    function setUp() public override {
        PRBProxyFactory_Test.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function test_Deploy() external {
        bytes memory actualRuntimeBytecode = address(factory.deploy()).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should update the next seeds mapping.
    function test_Deploy_UpdateNextSeeds() external {
        factory.deploy();
        bytes32 actualNextSeed = factory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "nextSeed");
    }

    /// @dev it should update the proxies mapping.
    function test_Deploy_UpdateProxies() external {
        IPRBProxy proxy = factory.deploy();
        bool isProxy = factory.isProxy(proxy);
        assertTrue(isProxy);
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_Deploy_Event() external {
        expectEmit();
        emit DeployProxy({
            origin: deployer,
            deployer: deployer,
            owner: deployer,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(deployer, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(deployer, SEED_ZERO))
        });
        factory.deploy();
    }
}
