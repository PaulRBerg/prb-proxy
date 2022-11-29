// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { stdError } from "forge-std/StdError.sol";
import { IPRBProxy } from "src/IPRBProxy.sol";
import { PRBProxyTest } from "../PRBProxyTest.t.sol";
import { TargetChangeOwner } from "../../shared/TargetChangeOwner.t.sol";
import { TargetDummy } from "../../shared/TargetDummy.t.sol";
import { TargetEcho } from "../../shared/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../../shared/TargetMinGasReserve.t.sol";

contract PRBProxy__Execute is PRBProxyTest {
    function setUp() public virtual override {
        super.setUp();
    }

    modifier CallerUnauthorized() {
        _;
    }

    /// @dev it should revert.
    function testCannotExecute__NoPermission() external CallerUnauthorized {
        changePrank(users.eve);
        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy__ExecutionUnauthorized.selector,
                owner,
                users.eve,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        prbProxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function testCannotExecute__PermissionDifferentTarget() external CallerUnauthorized {
        prbProxy.setPermission(envoy, address(targets.echo), TargetDummy.foo.selector, true);
        changePrank(envoy);

        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy__ExecutionUnauthorized.selector,
                owner,
                envoy,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        prbProxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function testCannotExecute__PermissionDifferentFunction() external CallerUnauthorized {
        prbProxy.setPermission(envoy, address(targets.dummy), TargetDummy.bar.selector, true);
        changePrank(envoy);

        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy__ExecutionUnauthorized.selector,
                owner,
                envoy,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        prbProxy.execute(address(targets.dummy), data);
    }

    modifier CallerAuthorized() {
        _;
    }

    /// @dev it should revert.
    function testCannotExecute__TargetNotContract(address nonContract) external CallerAuthorized {
        vm.assume(nonContract.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy__TargetNotContract.selector, nonContract));
        prbProxy.execute(nonContract, bytes(""));
    }

    modifier TargetContract() {
        _;
    }

    /// @dev it should revert.
    function testCannotExecute__GasStipendCalculationUnderflows() external CallerAuthorized TargetContract {
        // Set the min gas reserve.
        uint256 gasLimit = 10_000;
        prbProxy.execute(
            address(targets.minGasReserve),
            abi.encodeWithSelector(TargetMinGasReserve.setMinGasReserve.selector, gasLimit + 1)
        );

        // Run the test.
        bytes memory data = abi.encode(TargetEcho.echoUint256.selector, 0);
        console2.logBytes(data);
        vm.expectRevert(stdError.arithmeticError);
        prbProxy.execute{ gas: gasLimit }(address(targets.echo), data);
    }

    modifier GasStipendCalculationDoesNotUnderflow() {
        _;
    }

    /// @dev it should revert.
    function testCannotExecute__OwnerChangedDuringDelegateCall()
        external
        CallerAuthorized
        TargetContract
        GasStipendCalculationDoesNotUnderflow
    {
        bytes memory data = bytes.concat(TargetChangeOwner.changeOwner.selector);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy__OwnerChanged.selector, owner, address(0)));
        prbProxy.execute(address(targets.changeOwner), data);
    }
}
