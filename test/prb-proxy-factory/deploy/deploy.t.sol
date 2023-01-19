// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { Base_Test } from "../../Base.t.sol";
import { PRBProxyFactory_Test } from "../PRBProxyFactory.t.sol";

contract Deploy_Test is PRBProxyFactory_Test {
    address internal deployer;

    function setUp() public override {
        Base_Test.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function test_Deploy() external {
        bytes memory actualRuntimeBytecode = address(factory.deploy()).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should update the next seeds mapping.
    function test_Deploy_UpdateNextSeeds() external {
        factory.deploy();
        bytes32 actualNextSeed = factory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed);
    }

    /// @dev it should update the proxies mapping.
    function test_Deploy_UpdateProxies() external {
        IPRBProxy proxy = factory.deploy();
        bool isProxy = factory.isProxy(proxy);
        assertTrue(isProxy);
    }

    /// @dev it should emit a DeployProxy event.
    function test_Deploy_Event() external {
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ZERO));
        address proxyAddress = computeProxyAddress(deployer, SEED_ZERO);
        emit DeployProxy({
            origin: deployer,
            deployer: deployer,
            owner: deployer,
            seed: SEED_ZERO,
            salt: salt,
            proxy: IPRBProxy(proxyAddress)
        });
        factory.deploy();
    }
}
