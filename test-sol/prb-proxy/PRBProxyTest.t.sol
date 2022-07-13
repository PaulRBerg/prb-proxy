// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBProxy } from "../../src/PRBProxy.sol";
import { BaseTest } from "../BaseTest.t.sol";
import { TargetChangeOwner } from "../shared/TargetChangeOwner.t.sol";
import { TargetDummy } from "../shared/TargetDummy.t.sol";
import { TargetEcho } from "../shared/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../shared/TargetMinGasReserve.t.sol";

contract PRBProxyTest is BaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Targets {
        TargetChangeOwner changeOwner;
        TargetDummy dummy;
        TargetEcho echo;
        TargetMinGasReserve minGasReserve;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event Execute(address indexed target, bytes data, bytes response);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal envoy;
    address internal owner;
    PRBProxy internal prbProxy;
    Targets internal targets;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        envoy = users.bob;
        owner = users.alice;

        prbProxy = new PRBProxy();
        targets = Targets({
            changeOwner: new TargetChangeOwner(),
            dummy: new TargetDummy(),
            echo: new TargetEcho(),
            minGasReserve: new TargetMinGasReserve()
        });
    }
}
