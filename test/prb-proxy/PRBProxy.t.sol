// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { PRBProxy } from "src/PRBProxy.sol";

import { Base_Test } from "../Base.t.sol";
import { PluginChangeOwner } from "../helpers/plugins/PluginChangeOwner.t.sol";
import { PluginDummy } from "../helpers/plugins/PluginDummy.t.sol";
import { PluginEcho } from "../helpers/plugins/PluginEcho.t.sol";
import { PluginEmpty } from "../helpers/plugins/PluginEmpty.t.sol";
import { PluginPanic } from "../helpers/plugins/PluginPanic.t.sol";
import { PluginReverter } from "../helpers/plugins/PluginReverter.t.sol";
import { PluginSelfDestructer } from "../helpers/plugins/PluginSelfDestructer.t.sol";
import { TargetChangeOwner } from "../helpers/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "../helpers/targets/TargetDummy.t.sol";
import { TargetDummyWithFallback } from "../helpers/targets/TargetDummyWithFallback.t.sol";
import { TargetEcho } from "../helpers/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../helpers/targets/TargetMinGasReserve.t.sol";
import { TargetPanic } from "../helpers/targets/TargetPanic.t.sol";
import { TargetReverter } from "../helpers/targets/TargetReverter.t.sol";
import { TargetSelfDestructer } from "../helpers/targets/TargetSelfDestructer.t.sol";

contract PRBProxy_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Plugins {
        PluginChangeOwner changeOwner;
        PluginDummy dummy;
        PluginEcho echo;
        PluginEmpty empty;
        PluginPanic panic;
        PluginReverter reverter;
        PluginSelfDestructer selfDestructer;
    }

    struct Targets {
        TargetChangeOwner changeOwner;
        TargetDummy dummy;
        TargetDummyWithFallback dummyWithFallback;
        TargetEcho echo;
        TargetMinGasReserve minGasReserve;
        TargetPanic panic;
        TargetReverter reverter;
        TargetSelfDestructer selfDestructer;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event Execute(address indexed target, bytes data, bytes response);

    event InstallPlugin(IPRBProxyPlugin indexed plugin);

    event RunPlugin(IPRBProxyPlugin indexed plugin, bytes data, bytes response);

    event SetPermission(address indexed envoy, address indexed target, bytes4 indexed selector, bool permission);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    event UninstallPlugin(IPRBProxyPlugin indexed plugin);

    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal owner;
    Plugins internal plugins;
    Targets internal targets;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        owner = users.alice;

        plugins = Plugins({
            changeOwner: new PluginChangeOwner(),
            dummy: new PluginDummy(),
            echo: new PluginEcho(),
            empty: new PluginEmpty(),
            panic: new PluginPanic(),
            reverter: new PluginReverter(),
            selfDestructer: new PluginSelfDestructer()
        });
        targets = Targets({
            changeOwner: new TargetChangeOwner(),
            dummy: new TargetDummy(),
            dummyWithFallback: new TargetDummyWithFallback(),
            echo: new TargetEcho(),
            minGasReserve: new TargetMinGasReserve(),
            panic: new TargetPanic(),
            reverter: new TargetReverter(),
            selfDestructer: new TargetSelfDestructer()
        });
    }
}
