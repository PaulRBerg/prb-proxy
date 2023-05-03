// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetReverter is PRBProxyStorage {
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
