// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Registry_Test } from "../Registry.t.sol";

contract GetMethodsByProxy_Test is Registry_Test {
    function setUp() public virtual override {
        Registry_Test.setUp();
        proxy = registry.deploy();
    }

    function test_GetMethodsByProxy_Unknown() external {
        bytes4[] memory actualMethods = registry.getMethodsByProxy({ proxy: proxy, plugin: plugins.basic });
        bytes4[] memory expectedMethods;
        assertEq(actualMethods, expectedMethods, "methods not empty array");
    }

    modifier whenPluginKnown() {
        registry.installPlugin(plugins.basic);
        _;
    }

    function test_GetMethodsByProxy() external whenPluginKnown {
        bytes4[] memory actualMethods = registry.getMethodsByProxy({ proxy: proxy, plugin: plugins.basic });
        bytes4[] memory expectedMethods = plugins.basic.getMethods();
        assertEq(actualMethods, expectedMethods, "methods mismatch");
    }
}
