// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";
import "./PRBProxy.sol";

/// @title PRBProxyFactory
/// @author Paul Razvan Berg
contract PRBProxyFactory is IPRBProxyFactory {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxyFactory
    mapping(address => bool) public override isProxy;

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function deploy(bytes32 salt) external override returns (address payable proxy) {
        proxy = deployFor(msg.sender, salt);
    }

    /// @inheritdoc IPRBProxyFactory
    function deployFor(address owner, bytes32 salt) public override returns (address payable proxy) {
        // Load the proxy bytecode.
        bytes memory bytecode = type(PRBProxy).creationCode;

        // Prevent front running the salt by hashing the concatenation of msg.sender and the user-provided salt.
        salt = keccak256(abi.encode(tx.origin, salt));

        // Deploy the proxy with CREATE2.
        assembly {
            let endowment := 0
            let bytecodeStart := add(bytecode, 0x20)
            let bytecodeLength := mload(bytecode)
            proxy := create2(endowment, bytecodeStart, bytecodeLength, salt)
        }

        // Transfer the ownership from this factory contract to the specified owner.
        IPRBProxy(proxy)._transferOwnership(owner);

        // Mark the proxy as deployed in the mapping.
        isProxy[proxy] = true;

        // Log the proxy via en event.
        emit DeployProxy(msg.sender, owner, address(proxy));
    }
}
