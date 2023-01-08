// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

contract TargetPanic {
    function assertion() external pure {
        assert(false);
    }

    function divisionByZero() external pure returns (uint256) {
        uint256 x = 0;
        return type(uint256).max / x;
    }

    function arithmeticOverflow() external pure returns (uint256) {
        return type(uint256).max + 1;
    }

    function arithmeticUnderflow() external pure returns (uint256) {
        return type(uint256).min - 1;
    }
}
