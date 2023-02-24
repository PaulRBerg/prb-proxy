// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";

import { Base_Test } from "../Base.t.sol";

contract Helpers_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event SetPermission(address indexed envoy, address indexed target, bool permission);

    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal owner;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();
        owner = users.alice;
    }
}
