// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract TargetRevert {
    error TargetError();

    function revertWithNothing() external pure {
        revert();
    }

    function revertWithCustomError() external pure {
        revert TargetError();
    }

    function revertLackPayableModifier() external pure returns (uint256) {
        return 0;
    }

    function revertWithReason() external pure {
        revert("This is a reason");
    }

    function revertWithRequire() external pure {
        require(false);
    }
}
