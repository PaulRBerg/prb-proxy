// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

contract TargetReverter {
    error SomeError();

    function withNothing() external pure {
        revert();
    }

    function withCustomError() external pure {
        revert SomeError();
    }

    function withRequire() external pure {
        require(false);
    }

    function withReasonString() external pure {
        revert("You shall not pass");
    }

    function dueToNoPayableModifier() external pure returns (uint256) {
        return 0;
    }
}
