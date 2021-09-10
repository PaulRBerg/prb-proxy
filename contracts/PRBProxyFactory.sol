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

    /// INTERNAL STORAGE ///

    /// @dev Internal mapping to track all deployed proxies.
    mapping(address => bool) internal _isProxy;

    /// @dev Internal mapping to track used salts per EOA.
    mapping(address => bytes32) internal _salts;

    /// CONSTRUCTOR ///

    constructor(IPRBProxy implementation_) {
        implementation = implementation_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function isProxy(address proxy) external view override returns (bool result) {
        result = _isProxy[proxy];
    }

    /// @inheritdoc IPRBProxyFactory
    function salts(address eoa) external view override returns (bytes32 salt) {
        salt = _salts[eoa];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxyFactory
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    /// @inheritdoc IPRBProxyFactory
    function deployFor(address owner) public override returns (address payable proxy) {
        bytes32 salt = _salts[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided salt.
        bytes32 finalSalt = keccak256(abi.encode(tx.origin, salt));

        // Deploy the proxy as an EIP-1167 clone, via CREATE2.
        proxy = clone(finalSalt);

        // Initialize the proxy.
        IPRBProxy(proxy).initialize(owner);

        // Mark the proxy as deployed.
        _isProxy[proxy] = true;

        // Increment the salt.
        unchecked {
            _salts[tx.origin] = bytes32(uint256(salt) + 1);
        }

        // Log the proxy via en event.
        emit DeployProxy(tx.origin, msg.sender, owner, address(proxy));
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
