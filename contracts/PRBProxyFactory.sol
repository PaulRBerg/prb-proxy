// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./IPRBProxyFactory.sol";

/// @notice Emitted when the deployment of an EIP-1167 clone with CREATE2 fails.
error PRBProxyFactory__CloneFailed(bytes32 salt);

/// @title PRBProxyFactory
/// @author Paul Razvan Berg
contract PRBProxyFactory is IPRBProxyFactory {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxyFactory
    IPRBProxy public immutable override implementation;

    /// @inheritdoc IPRBProxyFactory
    mapping(address => bool) public override isProxy;

    /// CONSTRUCTOR ///

    constructor(IPRBProxy implementaton_) {
        implementation = implementaton_;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function deploy(bytes32 salt) external override returns (address payable proxy) {
        proxy = deployFor(msg.sender, salt);
    }

    /// @inheritdoc IPRBProxyFactory
    function deployFor(address owner, bytes32 salt) public override returns (address payable proxy) {
        // Prevent front-running the salt by hashing the concatenation of tx.origin and the user-provided salt.
        salt = keccak256(abi.encode(tx.origin, salt));

        // Deploy the proxy as an EIP-1167 clone, via CREATE2.
        proxy = clone(salt);

        // Initialize the proxy.
        IPRBProxy(proxy).initialize(owner);

        // Mark the proxy as deployed in the mapping.
        isProxy[proxy] = true;

        // Log the proxy via en event.
        emit DeployProxy(msg.sender, owner, address(proxy));
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///

    /// @dev Deploys an EIP-1167 clone that mimics the behavior of `implementation`.
    function clone(bytes32 salt) internal returns (address payable proxy) {
        bytes20 impl = bytes20(address(implementation));
        assembly {
            let bytecode := mload(0x40)
            mstore(bytecode, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(bytecode, 0x14), impl)
            mstore(add(bytecode, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create2(0, bytecode, 0x37, salt)
        }
        if (proxy == address(0)) {
            revert PRBProxyFactory__CloneFailed(salt);
        }
    }
}
