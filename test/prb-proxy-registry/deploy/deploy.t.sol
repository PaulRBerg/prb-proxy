// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { PRBProxyRegistry_Test } from "../PRBProxyRegistry.t.sol";

contract Deploy_Test is PRBProxyRegistry_Test {
    address internal deployer;

    function setUp() public override {
        PRBProxyRegistry_Test.setUp();
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
}
