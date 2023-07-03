// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { TargetEcho } from "../../mocks/targets/TargetEcho.sol";
import { TargetReverter } from "../../mocks/targets/TargetReverter.sol";
import { Proxy_Test } from "../Proxy.t.sol";

contract Execute_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    modifier whenCallerUnauthorized() {
        _;
    }

    function test_RevertWhen_NoPermission() external whenCallerUnauthorized {
        changePrank({ msgSender: users.eve });
        bytes memory data = bytes.concat(targets.basic.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, users.eve, address(targets.basic)
            )
        );
        proxy.execute(address(targets.basic), data);
    }

    function test_RevertWhen_PermissionDifferentTarget() external whenCallerUnauthorized {
        registry.setPermission({ envoy: users.envoy, target: address(targets.echo), permission: true });
        changePrank({ msgSender: users.envoy });

        bytes memory data = bytes.concat(targets.basic.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, users.envoy, address(targets.basic)
            )
        );
        proxy.execute(address(targets.basic), data);
    }

    modifier whenCallerAuthorized() {
        _;
    }

    function test_RevertWhen_TargetNotContract(address nonContract) external whenCallerAuthorized {
        vm.assume(nonContract.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_TargetNotContract.selector, nonContract));
        proxy.execute(nonContract, bytes(""));
    }

    modifier whenTargetContract() {
        _;
    }

    modifier whenDelegateCallReverts() {
        _;
    }

    function test_RevertWhen_Panic_FailedAssertion()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.failedAssertion.selector);
        vm.expectRevert(stdError.assertionError);
        proxy.execute(address(targets.panic), data);
    }

    function test_RevertWhen_Panic_ArithmeticOverflow()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.arithmeticOverflow.selector);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute(address(targets.panic), data);
    }

    function test_RevertWhen_Panic_DivisionByZero()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.divisionByZero.selector);
        vm.expectRevert(stdError.divisionError);
        proxy.execute(address(targets.panic), data);
    }

    function test_RevertWhen_Panic_IndexOOB()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.indexOOB.selector);
        vm.expectRevert(stdError.indexOOBError);
        proxy.execute(address(targets.panic), data);
    }

    function test_RevertWhen_Error_EmptyRevertStatement()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withNothing.selector);
        vm.expectRevert(IPRBProxy.PRBProxy_ExecutionReverted.selector);
        proxy.execute(address(targets.reverter), data);
    }

    function test_RevertWhen_Error_CustomError()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withCustomError.selector);
        vm.expectRevert(TargetReverter.SomeError.selector);
        proxy.execute(address(targets.reverter), data);
    }

    function test_RevertWhen_Error_Require() external whenCallerAuthorized whenTargetContract whenDelegateCallReverts {
        bytes memory data = bytes.concat(targets.reverter.withRequire.selector);
        vm.expectRevert();
        proxy.execute(address(targets.reverter), data);
    }

    function test_RevertWhen_Error_ReasonString()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.withReasonString.selector);
        vm.expectRevert("You shall not pass");
        proxy.execute(address(targets.reverter), data);
    }

    function test_RevertWhen_Error_NoPayableModifier()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallReverts
    {
        bytes memory data = bytes.concat(targets.reverter.dueToNoPayableModifier.selector);
        vm.expectRevert();
        proxy.execute{ value: 0.1 ether }(address(targets.reverter), data);
    }

    modifier whenDelegateCallDoesNotRevert() {
        _;
    }

    function test_Execute_EtherSent() external whenCallerAuthorized whenTargetContract whenDelegateCallDoesNotRevert {
        uint256 amount = 0.1 ether;
        bytes memory data = bytes.concat(targets.echo.echoMsgValue.selector);
        bytes memory actualResponse = proxy.execute{ value: amount }(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse, "echo.echoMsgValue response mismatch");
    }

    modifier whenNoEtherSent() {
        _;
    }

    function test_Execute_TargetSelfDestructs()
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
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
        assertEq(actualResponse, expectedResponse, "selfDestructer response mismatch");

        // Assert that Bob's balance has increased by the contract's balance.
        uint256 actualBobBalance = users.bob.balance;
        uint256 expectedAliceBalance = initialBobBalance + proxyBalance;
        assertEq(actualBobBalance, expectedAliceBalance, "selfDestructer balance");
    }

    modifier whenTargetDoesNotSelfDestruct() {
        registry.setPermission({ envoy: users.envoy, target: address(targets.echo), permission: true });
        _;
    }

    /// @dev This modifier runs the test twice, once with the owner as the caller, and once with the envoy.
    modifier whenCallerOwnerOrEnvoy() {
        _;
        changePrank({ msgSender: users.envoy });
        _;
    }

    function testFuzz_Execute_ReturnAddress(address input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoAddress, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoAddress response mismatch");
    }

    function testFuzz_Execute_ReturnBytesArray(bytes memory input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytesArray, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoBytesArray response mismatch");
    }

    function testFuzz_Execute_ReturnBytes32(bytes32 input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytes32, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoBytes32 response mismatch");
    }

    function testFuzz_Execute_ReturnString(string memory input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoString, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoString response mismatch");
    }

    function testFuzz_Execute_ReturnStruct(TargetEcho.SomeStruct memory input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoStruct, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoStruct response mismatch");
    }

    function testFuzz_Execute_ReturnUint8(uint8 input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint8, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint8 response mismatch");
    }

    function testFuzz_Execute_ReturnUint256(uint256 input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response mismatch");
    }

    function testFuzz_Execute_ReturnUint256Array(uint256[] memory input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256Array, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256Array response mismatch");
    }

    function testFuzz_Execute_Event(uint256 input)
        external
        whenCallerAuthorized
        whenTargetContract
        whenDelegateCallDoesNotRevert
        whenNoEtherSent
        whenTargetDoesNotSelfDestruct
        whenCallerOwnerOrEnvoy
    {
        vm.expectEmit({ emitter: address(proxy) });
        bytes memory data = abi.encodeCall(targets.echo.echoUint256, (input));
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        proxy.execute(address(targets.echo), data);
    }
}
