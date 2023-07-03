// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

contract TargetEcho {
    struct SomeStruct {
        uint256 foo;
        uint256 bar;
        uint256 baz;
    }

    function echoAddress(address input) external pure returns (address) {
        return input;
    }

    function echoBytesArray(bytes memory input) external pure returns (bytes memory) {
        return input;
    }

    function echoBytes32(bytes32 input) external pure returns (bytes32) {
        return input;
    }

    function echoMsgValue() external payable returns (uint256) {
        return msg.value;
    }

    function echoString(string memory input) external pure returns (string memory) {
        return input;
    }

    function echoStruct(SomeStruct calldata input) external pure returns (SomeStruct calldata) {
        return input;
    }

    function echoUint8(uint8 input) external pure returns (uint8) {
        return input;
    }

    function echoUint256(uint256 input) external pure returns (uint256) {
        return input;
    }

    function echoUint256Array(uint256[] calldata input) external pure returns (uint256[] calldata) {
        return input;
    }
}
