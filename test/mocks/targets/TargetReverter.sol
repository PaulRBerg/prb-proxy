// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

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

    function notPayable() external pure returns (uint256) {
        return 0;
    }
}
