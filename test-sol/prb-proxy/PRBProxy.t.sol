// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { PRBProxy } from "src/PRBProxy.sol";

import { BaseTest } from "../BaseTest.t.sol";
import { TargetChangeOwner } from "../helpers/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "../helpers/targets/TargetDummy.t.sol";
import { TargetEcho } from "../helpers/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../helpers/targets/TargetMinGasReserve.t.sol";

contract PRBProxy_Test is BaseTest {
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
                                      STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    address internal envoy;
    address internal owner;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    PRBProxy internal proxy;
    Targets internal targets;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        BaseTest.setUp();
        envoy = users.bob;
        owner = users.alice;

        proxy = new PRBProxy();
        targets = Targets({
            changeOwner: new TargetChangeOwner(),
            dummy: new TargetDummy(),
            echo: new TargetEcho(),
            minGasReserve: new TargetMinGasReserve()
        });
    }
}
