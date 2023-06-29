// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { TargetBasic } from "../../mocks/targets/TargetBasic.sol";
import { TargetReverter } from "../../mocks/targets/TargetReverter.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract RunPlugin_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    function test_RevertWhen_PluginNotInstalled() external {
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_PluginNotInstalledForMethod.selector, address(owner), plugins.basic.foo.selector
            )
        );
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.basic.foo.selector));
        success;
    }

    modifier whenPluginInstalled() {
        _;
    }

    modifier whenDelegateCallReverts() {
        _;
    }

    function test_RevertWhen_Panic_FailedAssertion() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.panic);
        vm.expectRevert(stdError.assertionError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.failedAssertion.selector));
        success;
    }

    function test_RevertWhen_Panic_ArithmeticOverflow() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.arithmeticOverflow.selector));
        success;
    }

    function test_RevertWhen_Panic_DivisionByZero() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.divisionByZero.selector));
        success;
    }

    function test_RevertWhen_Panic_IndexOOB() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.panic);
        vm.expectRevert(stdError.arithmeticError);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.panic.indexOOB.selector));
        success;
    }

    function test_RevertWhen_Error_EmptyRevertStatement() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.reverter);
        vm.expectRevert(IPRBProxy.PRBProxy_PluginReverted.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withNothing.selector));
        success;
    }

    function test_RevertWhen_Error_CustomError() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withCustomError.selector));
        success;
    }

    function test_RevertWhen_Error_Require() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.reverter);
        vm.expectRevert(TargetReverter.SomeError.selector);
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.reverter.withRequire.selector));
        success;
    }

    function test_RevertWhen_Error_ReasonString() external whenPluginInstalled whenDelegateCallReverts {
        registry.installPlugin(plugins.reverter);
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
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
    {
        registry.installPlugin(plugins.echo);
        uint256 amount = 0.1 ether;
        (, bytes memory actualResponse) =
            address(proxy).call{ value: amount }(abi.encodeWithSelector(plugins.echo.echoMsgValue.selector));
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse, "echo.echoMsgValue response mismatch");
    }

    modifier whenNoEtherSent() {
        _;
    }

    function test_RunPlugin_PluginSelfDestructs()
        external
        whenPluginInstalled
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
        registry.installPlugin(plugins.selfDestructer);
        (bool success,) =
            address(proxy).call(abi.encodeWithSelector(plugins.selfDestructer.destroyMe.selector, users.bob));
        success;

        // Assert that Bob's balance has increased by the contract's balance.
        uint256 actualBobBalance = users.bob.balance;
        uint256 expectedAliceBalance = initialBobBalance + proxyBalance;
        assertEq(actualBobBalance, expectedAliceBalance, "selfDestructer.destroyMe balance mismatch");
    }

    modifier whenPluginDoesNotSelfDestruct() {
        _;
    }

    function test_RunPlugin()
        external
        whenPluginInstalled
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenPluginDoesNotSelfDestruct
    {
        registry.installPlugin(plugins.basic);
        (, bytes memory actualResponse) = address(proxy).call(abi.encodeWithSelector(plugins.basic.foo.selector));
        bytes memory expectedResponse = abi.encode(bytes("foo"));
        assertEq(actualResponse, expectedResponse, "basic.foo response mismatch");
    }

    function test_RunPlugin_Event()
        external
        whenPluginInstalled
        whenDelegateCallReverts
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenPluginDoesNotSelfDestruct
    {
        registry.installPlugin(plugins.basic);
        vm.expectEmit({ emitter: address(proxy) });
        emit RunPlugin({
            plugin: plugins.basic,
            data: abi.encodeWithSelector(TargetBasic.foo.selector),
            response: abi.encode(bytes("foo"))
        });
        (bool success,) = address(proxy).call(abi.encodeWithSelector(plugins.basic.foo.selector));
        success;
    }
}
