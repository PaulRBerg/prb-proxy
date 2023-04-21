// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { PluginChangeOwner } from "../../mocks/plugins/PluginChangeOwner.sol";
import { PluginEcho } from "../../mocks/plugins/PluginEcho.sol";
import { PluginDummy } from "../../mocks/plugins/PluginDummy.sol";
import { PluginPanic } from "../../mocks/plugins/PluginPanic.sol";
import { PluginReverter } from "../../mocks/plugins/PluginReverter.sol";
import { PluginSelfDestructer } from "../../mocks/plugins/PluginSelfDestructer.sol";
import { TargetDummy } from "../../mocks/targets/TargetDummy.sol";
import { TargetReverter } from "../../mocks/targets/TargetReverter.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract RunPlugin_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    function test_RevertWhen_PluginNotInstalled() external {
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_PluginNotInstalledForMethod.selector, address(owner), plugins.dummy.foo.selector
            )
        );
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }

    modifier whenPluginInstalled() {
        _;
    }

    function test_RevertWhen_GasStipendCalculationUnderflows() external whenPluginInstalled {
        // Install the dummy plugin.
        installPlugin(plugins.dummy);

        // Set the min gas reserve.
        uint256 gasLimit = 10_000;
        proxy.execute(
            address(targets.minGasReserve),
            abi.encodeWithSelector(targets.minGasReserve.setMinGasReserve.selector, gasLimit + 1)
        );

        // Except an arithmetic underflow.
        vm.expectRevert(stdError.arithmeticError);

        // Run the plugin.
        (bool success,) = address(proxy).call{ gas: gasLimit }(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }

    modifier whenGasStipendCalculationDoesNotUnderflow() {
        _;
    }

    function test_RevertWhen_OwnerChangedDuringDelegateCall()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
    {
        installPlugin(plugins.changeOwner);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_OwnerChanged.selector, owner, address(1729)));
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.changeOwner.changeIt.selector));
        success;
    }

    modifier whenOwnerNotChangedDuringDelegateCall() {
        _;
    }

    modifier whenDelegateCallReverts() {
        _;
    }

    function test_RevertWhen_Panic_FailedAssertion()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.assertionError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.failedAssertion.selector));
        success;
    }

    function test_RevertWhen_Panic_ArithmeticOverflow()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.arithmeticOverflow.selector));
        success;
    }

    function test_RevertWhen_Panic_DivisionByZero()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.divisionByZero.selector));
        success;
    }

    function test_RevertWhen_Panic_IndexOOB()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.indexOOB.selector));
        success;
    }

    function test_RevertWhen_Error_EmptyRevertStatement()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(IPRBProxy.PRBProxy_PluginReverted.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withNothing.selector));
        success;
    }

    function test_RevertWhen_Error_CustomError()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withCustomError.selector));
        success;
    }

    function test_RevertWhen_Error_Require()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withRequire.selector));
        success;
    }

    function test_RevertWhen_Error_ReasonString()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert("You shall not pass");
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withReasonString.selector));
        success;
    }

    modifier whenDelegateCallDoesNotRevert() {
        _;
    }

    function test_RunPlugin_EtherSent()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
    {
        installPlugin(plugins.echo);
        uint256 amount = 0.1 ether;
        (, bytes memory actualResponse) =
            address(proxy).call{ value: amount }(abi.encodeWithSelector(plugins.echo.echoMsgValue.selector));
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse, "echo.echoMsgValue response");
    }

    modifier whenNoEtherSent() {
        _;
    }

    function test_RunPlugin_PluginSelfDestructs()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
    {
        // Load Bob's initial balance.
        uint256 initialBobBalance = users.bob.balance;

        // Set the proxy's balance.
        uint256 proxyBalance = 3.14 ether;
        vm.deal({ account: address(proxy), newBalance: proxyBalance });

        // Install the plugin and run it.
        installPlugin(plugins.selfDestructer);
        (bool success,) =
            address(proxy).call(abi.encodeWithSelector(plugins.selfDestructer.destroyMe.selector, users.bob));
        success;

        // Assert that Bob's balance has increased by the contract's balance.
        uint256 actualBobBalance = users.bob.balance;
        uint256 expectedAliceBalance = initialBobBalance + proxyBalance;
        assertEq(actualBobBalance, expectedAliceBalance, "selfDestructer.destroyMe balance");
    }

    modifier whenPluginDoesNotSelfDestruct() {
        _;
    }

    function test_RunPlugin()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenPluginDoesNotSelfDestruct
    {
        installPlugin(plugins.dummy);
        (, bytes memory actualResponse) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        bytes memory expectedResponse = abi.encode(bytes("foo"));
        assertEq(actualResponse, expectedResponse, "dummy.foo response");
    }

    function test_RunPlugin_Event()
        external
        whenPluginInstalled
        whenGasStipendCalculationDoesNotUnderflow
        whenOwnerNotChangedDuringDelegateCall
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenPluginDoesNotSelfDestruct
    {
        installPlugin(plugins.dummy);
        vm.expectEmit();
        emit RunPlugin({
            plugin: plugins.dummy,
            data: abi.encodeWithSelector(TargetDummy.foo.selector),
            response: abi.encode(bytes("foo"))
        });
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }
}
