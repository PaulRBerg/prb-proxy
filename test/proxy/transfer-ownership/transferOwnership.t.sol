// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Proxy_Test } from "../Proxy.t.sol";

contract TransferOwnership_Test is Proxy_Test {
    function setUp() public virtual override {
        Proxy_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_CallerNotRegistry() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank({ msgSender: caller });

        // Run the test.
        address newOwner = users.eve;
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_CallerNotRegistry.selector, registry, caller));
        proxy.transferOwnership(newOwner);
    }

    modifier callerRegistry() {
        changePrank({ msgSender: address(registry) });
        _;
    }

    /// @dev it should transfer the ownership.
    function testFuzz_TransferOwnership(address newOwner) external callerRegistry {
        vm.assume(newOwner != users.alice);

        proxy.transferOwnership(newOwner);
        address actualOwner = proxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner, "proxy owner");
    }
}
