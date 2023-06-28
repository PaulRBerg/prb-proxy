// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Registry_Test } from "../Registry.t.sol";

contract GetPluginByProxy_Test is Registry_Test {
    function setUp() public virtual override {
        Registry_Test.setUp();
        proxy = registry.deploy();
    }

    function test_GetPluginByProxy_Uninstalled() external {
        address actualPlugin = address(registry.getPluginByProxy({ proxy: proxy, method: plugins.dummy.foo.selector }));
        address expectedPlugin = address(0);
        assertEq(actualPlugin, expectedPlugin, "plugin not zero address");
    }

    modifier whenPluginInstalled() {
        registry.installPlugin(plugins.dummy);
        _;
    }

    function test_GetPluginByProxy() external whenPluginInstalled {
        address actualPlugin = address(registry.getPluginByProxy({ proxy: proxy, method: plugins.dummy.foo.selector }));
        address expectedPlugin = address(plugins.dummy);
        assertEq(actualPlugin, expectedPlugin, "plugin address mismatch");
    }
}
