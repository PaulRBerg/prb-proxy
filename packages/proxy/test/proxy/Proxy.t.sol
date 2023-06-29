// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { Base_Test } from "../Base.t.sol";

contract Proxy_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal owner;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Make Alice the owner of the default proxy.
        owner = users.alice;

        // Deploy and label the default proxy.
        proxy = registry.deployFor({ owner: users.alice });
        vm.label({ account: address(proxy), newLabel: "Alice Proxy" });
    }
}
