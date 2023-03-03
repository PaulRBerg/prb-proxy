// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { TargetEcho } from "../../shared/targets/TargetEcho.t.sol";
import { TargetReverter } from "../../shared/targets/TargetReverter.t.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract Execute_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    modifier callerUnauthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_NoPermission() external callerUnauthorized {
        changePrank({ msgSender: users.eve });
        bytes memory data = bytes.concat(targets.dummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, users.eve, address(targets.dummy)
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_PermissionDifferentTarget() external callerUnauthorized {
        setPermission({ envoy: users.envoy, target: address(targets.echo), permission: true });
        changePrank({ msgSender: users.envoy });

        bytes memory data = bytes.concat(targets.dummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, users.envoy, address(targets.dummy)
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    modifier callerAuthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TargetNotContract(address nonContract) external callerAuthorized {
        vm.assume(nonContract.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_TargetNotContract.selector, nonContract));
        proxy.execute(nonContract, bytes(""));
    }

    modifier targetContract() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_GasStipendCalculationUnderflows() external callerAuthorized targetContract {
        // Set the min gas reserve.
        uint256 gasLimit = 10_000;
        proxy.execute(
            address(targets.minGasReserve),
            abi.encodeWithSelector(targets.minGasReserve.setMinGasReserve.selector, gasLimit + 1)
        );

        // Run the test.
        bytes memory data = abi.encode(targets.echo.echoUint256.selector, 1729);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute{ gas: gasLimit }(address(targets.echo), data);
    }

    modifier gasStipendCalculationDoesNotUnderflow() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerChangedDuringDelegateCall()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
    {
        bytes memory data = bytes.concat(targets.changeOwner.changeIt.selector);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_OwnerChanged.selector, owner, address(1729)));
        proxy.execute(address(targets.changeOwner), data);
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
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.failedAssertion.selector);
        vm.expectRevert(stdError.assertionError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_ArithmeticOverflow()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.arithmeticOverflow.selector);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_DivisionByZero()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.divisionByZero.selector);
        vm.expectRevert(stdError.divisionError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_IndexOOB()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.indexOOB.selector);
        vm.expectRevert(stdError.indexOOBError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_EmptyRevertStatement()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withNothing.selector);
        vm.expectRevert(IPRBProxy.PRBProxy_ExecutionReverted.selector);
        proxy.execute(address(targets.reverter), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_CustomError()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withCustomError.selector);
        vm.expectRevert(TargetReverter.SomeError.selector);
        proxy.execute(address(targets.reverter), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_Require()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withRequire.selector);
        vm.expectRevert();
        proxy.execute(address(targets.reverter), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_ReasonString()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withReasonString.selector);
        vm.expectRevert("You shall not pass");
        proxy.execute(address(targets.reverter), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_NoPayableModifier()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.dueToNoPayableModifier.selector);
        vm.expectRevert();
        proxy.execute{ value: 0.1 ether }(address(targets.reverter), data);
    }

    modifier delegateCallDoesNotRevert() {
        _;
    }

    /// @dev it should return the Ether amount.
    function test_Execute_EtherSent()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
    {
        uint256 amount = 0.1 ether;
        bytes memory data = bytes.concat(targets.echo.echoMsgValue.selector);
        bytes memory actualResponse = proxy.execute{ value: amount }(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse, "echo.echoMsgValue response");
    }

    modifier noEtherSent() {
        _;
    }

    /// @dev it should return an empty response and send the ETH to the SELFDESTRUCT recipient.
    function test_Execute_TargetSelfDestructs()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
    {
        // Load Bob's initial balance.
        uint256 initialBobBalance = users.bob.balance;

        // Set the proxy's balance.
        uint256 proxyBalance = 3.14 ether;
        vm.deal({ account: address(proxy), newBalance: proxyBalance });

        // Call the target contract.
        bytes memory data = abi.encodeCall(targets.selfDestructer.destroyMe, (users.bob));
        bytes memory actualResponse = proxy.execute(address(targets.selfDestructer), data);
        bytes memory expectedResponse = "";

        // Assert that the response is empty.
        assertEq(actualResponse, expectedResponse, "selfDestructer response");

        // Assert that Bob's balance has increased by the contract's balance.
        uint256 actualBobBalance = users.bob.balance;
        uint256 expectedAliceBalance = initialBobBalance + proxyBalance;
        assertEq(actualBobBalance, expectedAliceBalance, "selfDestructer balance");
    }

    modifier targetDoesNotSelfDestruct() {
        setPermission({ envoy: users.envoy, target: address(targets.echo), permission: true });
        _;
    }

    /// @dev This modifier runs the test twice, once with the owner as the caller, and once with the envoy.
    modifier callerOwnerOrEnvoy() {
        _;
        changePrank({ msgSender: users.envoy });
        _;
    }

    /// @dev it should return the address.
    function testFuzz_Execute_ReturnAddress(address input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoAddress, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoAddress response");
    }

    /// @dev it should return the bytes array.
    function testFuzz_Execute_ReturnBytesArray(bytes memory input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytesArray, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoBytesArray response");
    }

    /// @dev it should return the bytes32.
    function testFuzz_Execute_ReturnBytes32(bytes32 input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytes32, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoBytes32 response");
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnString(string memory input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoString, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoString response");
    }

    /// @dev it should return the struct.
    function testFuzz_Execute_ReturnStruct(TargetEcho.SomeStruct memory input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoStruct, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoStruct response");
    }

    /// @dev it should return the uint8.
    function testFuzz_Execute_ReturnUint8(uint8 input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint8, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint8 response");
    }

    /// @dev it should return the uint256.
    function testFuzz_Execute_ReturnUint256(uint256 input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response");
    }

    /// @dev it should return the uint256 array.
    function testFuzz_Execute_ReturnUint256Array(uint256[] memory input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256Array, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256Array response");
    }

    /// @dev it should emit an {Execute} event.
    function testFuzz_Execute_Event(uint256 input)
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerOrEnvoy
    {
        expectEmit();
        bytes memory data = abi.encodeCall(targets.echo.echoUint256, (input));
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        proxy.execute(address(targets.echo), data);
    }
}
