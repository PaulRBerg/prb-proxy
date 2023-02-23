// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { PluginChangeOwner } from "../../shared/plugins/PluginChangeOwner.t.sol";
import { PluginEcho } from "../../shared/plugins/PluginEcho.t.sol";
import { PluginDummy } from "../../shared/plugins/PluginDummy.t.sol";
import { PluginPanic } from "../../shared/plugins/PluginPanic.t.sol";
import { PluginReverter } from "../../shared/plugins/PluginReverter.t.sol";
import { PluginSelfDestructer } from "../../shared/plugins/PluginSelfDestructer.t.sol";
import { TargetDummy } from "../../shared/targets/TargetDummy.t.sol";
import { TargetReverter } from "../../shared/targets/TargetReverter.t.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract RunPlugin_Test is Proxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_PluginNotInstalled() external {
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_PluginNotInstalledForMethod.selector,
                address(owner),
                plugins.dummy.foo.selector
            )
        );
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }

    modifier pluginInstalled() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_GasStipendCalculationUnderflows() external pluginInstalled {
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
        (bool success, ) = address(proxy).call{ gas: gasLimit }(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }

    modifier gasStipendCalculationDoesNotUnderflow() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerChangedDuringDelegateCall()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
    {
        installPlugin(plugins.changeOwner);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_OwnerChanged.selector, owner, address(1729)));
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.changeOwner.changeIt.selector));
        success;
    }

    modifier ownerNotChangedDuringDelegateCall() {
        _;
    }

    modifier delegateCallReverts() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_FailedAssertion()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.assertionError);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.panic.failedAssertion.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_ArithmeticOverflow()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.panic.arithmeticOverflow.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_DivisionByZero()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.panic.divisionByZero.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_IndexOOB()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.panic.indexOOB.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_EmptyRevertStatement()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(IPRBProxy.PRBProxy_PluginReverted.selector);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withNothing.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_CustomError()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withCustomError.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_Require()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withRequire.selector));
        success;
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_ReasonString()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        installPlugin(plugins.reverter);
        vm.expectRevert("You shall not pass");
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withReasonString.selector));
        success;
    }

    modifier delegateCallDoesNotRevert() {
        _;
    }

    /// @dev it should return the Ether amount.
    function test_RunPlugin_EtherSent()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
        delegateCallDoesNotRevert
    {
        installPlugin(plugins.echo);
        uint256 amount = 0.1 ether;
        (, bytes memory actualResponse) = address(proxy).call{ value: amount }(
            abi.encodeWithSelector(plugins.echo.echoMsgValue.selector)
        );
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse, "echo.echoMsgValue response");
    }

    modifier noEtherSent() {
        _;
    }

    /// @dev it should return an empty response and send the ETH to the SELFDESTRUCT recipient.
    function test_RunPlugin_PluginSelfDestructs()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
        delegateCallDoesNotRevert
        noEtherSent
    {
        // Load Bob's initial balance.
        uint256 initialBobBalance = users.bob.balance;

        // Set the proxy's balance.
        uint256 proxyBalance = 3.14 ether;
        vm.deal({ account: address(proxy), newBalance: proxyBalance });

        // Install the plugin and run it.
        installPlugin(plugins.selfDestructer);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(plugins.selfDestructer.destroyMe.selector, users.bob)
        );
        success;

        // Assert that Bob's balance has increased by the contract's balance.
        uint256 actualBobBalance = users.bob.balance;
        uint256 expectedAliceBalance = initialBobBalance + proxyBalance;
        assertEq(actualBobBalance, expectedAliceBalance, "selfDestructer.destroyMe balance");
    }

    modifier pluginDoesNotSelfDestruct() {
        _;
    }

    /// @dev it should run the plugin.
    function test_RunPlugin_Zzz()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
        delegateCallDoesNotRevert
        noEtherSent
        pluginDoesNotSelfDestruct
    {
        installPlugin(plugins.dummy);
        (, bytes memory actualResponse) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        bytes memory expectedResponse = abi.encode(bytes("foo"));
        assertEq(actualResponse, expectedResponse, "dummy.foo response");
    }

    /// @dev it should emit a {RunPlugin} event.
    function test_RunPlugin_Event()
        external
        pluginInstalled
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
        delegateCallDoesNotRevert
        noEtherSent
        pluginDoesNotSelfDestruct
    {
        installPlugin(plugins.dummy);
        expectEmit();
        emit RunPlugin({
            plugin: plugins.dummy,
            data: abi.encodeWithSelector(TargetDummy.foo.selector),
            response: abi.encode(bytes("foo"))
        });
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(plugins.dummy.foo.selector));
        success;
    }
}
