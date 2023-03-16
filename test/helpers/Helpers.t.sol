// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Base_Test } from "../Base.t.sol";

contract Helpers_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal owner;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Make Alice the owner of the default proxy.
        owner = users.alice;

        // Deploy and label the default proxy.
        proxy = registry.deployFor({ owner: users.alice });
        vm.label({ account: address(proxy), newLabel: "Default Proxy" });
    }
}
