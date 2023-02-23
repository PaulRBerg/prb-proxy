// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { PRBProxy } from "src/PRBProxy.sol";

import { Base_Test } from "../Base.t.sol";

contract PRBProxy_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    event SetPermission(address indexed envoy, address indexed target, bool permission);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal owner;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        owner = users.alice;
    }
}
