// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";
import "./PRBProxy.sol";

/// @title PRBProxyFactory
/// @author Paul Razvan Berg
contract PRBProxyFactory is IPRBProxyFactory {
    /// PUBLIC STORAGE ///

    /// INTERNAL STORAGE ///

    /// @dev Internal mapping to track all deployed proxies.
    mapping(address => bool) internal proxies;

    /// @dev Internal mapping to track the next salt to be used by an EOA.
    mapping(address => bytes32) internal nextSalts;

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function getNextSalt(address eoa) external view override returns (bytes32 nextSalt) {
        nextSalt = nextSalts[eoa];
    }

    /// @inheritdoc IPRBProxyFactory
    function isProxy(address proxy) external view override returns (bool result) {
        result = proxies[proxy];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    /// @inheritdoc IPRBProxyFactory
    function deployFor(address owner) public override returns (address payable proxy) {
        bytes32 salt = nextSalts[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided salt.
        bytes32 finalSalt = keccak256(abi.encode(tx.origin, salt));

        // Load the proxy bytecode.
        bytes memory bytecode = type(PRBProxy).creationCode;

        // Deploy the proxy with CREATE2.
        assembly {
            let endowment := 0
            let bytecodeStart := add(bytecode, 0x20)
            let bytecodeLength := mload(bytecode)
            proxy := create2(endowment, bytecodeStart, bytecodeLength, finalSalt)
        }

        // Transfer the ownership from this factory contract to the specified owner.
        IPRBProxy(proxy).transferOwnership(owner);

        // Mark the proxy as deployed.
        proxies[proxy] = true;

        // Increment the salt.
        unchecked {
            nextSalts[tx.origin] = bytes32(uint256(salt) + 1);
        }

        // Log the proxy via en event.
        emit DeployProxy(tx.origin, msg.sender, owner, salt, finalSalt, address(proxy));
    }
}
