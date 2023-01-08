// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { TargetChangeOwner } from "../../helpers/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "../../helpers/targets/TargetDummy.t.sol";
import { TargetEcho } from "../../helpers/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "../../helpers/targets/TargetMinGasReserve.t.sol";

contract Execute_Test is PRBProxy_Test {
    modifier CallerUnauthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_NoPermission() external CallerUnauthorized {
        changePrank(users.eve);
        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                owner,
                users.eve,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_PermissionDifferentTarget() external CallerUnauthorized {
        proxy.setPermission(envoy, address(targets.echo), TargetDummy.foo.selector, true);
        changePrank(envoy);

        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                owner,
                envoy,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_PermissionDifferentFunction() external CallerUnauthorized {
        proxy.setPermission(envoy, address(targets.dummy), TargetDummy.bar.selector, true);
        changePrank(envoy);

        bytes memory data = bytes.concat(TargetDummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                owner,
                envoy,
                address(targets.dummy),
                TargetDummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    modifier CallerAuthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TargetNotContract(address nonContract) external CallerAuthorized {
        vm.assume(nonContract.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_TargetNotContract.selector, nonContract));
        proxy.execute(nonContract, bytes(""));
    }

    modifier TargetContract() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_GasStipendCalculationUnderflows() external CallerAuthorized TargetContract {
        // Set the min gas reserve.
        uint256 gasLimit = 10_000;
        proxy.execute(
            address(targets.minGasReserve),
            abi.encodeWithSelector(TargetMinGasReserve.setMinGasReserve.selector, gasLimit + 1)
        );

        // Run the test.
        bytes memory data = abi.encode(TargetEcho.echoUint256.selector, 0);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute{ gas: gasLimit }(address(targets.echo), data);
    }

    modifier GasStipendCalculationDoesNotUnderflow() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerChangedDuringDelegateCall()
        external
        CallerAuthorized
        TargetContract
        GasStipendCalculationDoesNotUnderflow
    {
        bytes memory data = bytes.concat(TargetChangeOwner.changeOwner.selector);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_OwnerChanged.selector, owner, address(0)));
        proxy.execute(address(targets.changeOwner), data);
    }
}
