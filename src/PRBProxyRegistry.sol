// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "./interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "./PRBProxy.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

██████╗ ███████╗ ██████╗ ██╗███████╗████████╗██████╗ ██╗   ██╗
██╔══██╗██╔════╝██╔════╝ ██║██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝
██████╔╝█████╗  ██║  ███╗██║███████╗   ██║   ██████╔╝ ╚████╔╝
██╔══██╗██╔══╝  ██║   ██║██║╚════██║   ██║   ██╔══██╗  ╚██╔╝
██║  ██║███████╗╚██████╔╝██║███████║   ██║   ██║  ██║   ██║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝

*/

/// @title PRBProxyRegistry
/// @dev See the documentation in {IPRBProxyRegistry}.
contract PRBProxyRegistry is IPRBProxyRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    string public constant override VERSION = "4.0.0-beta.3";

    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    mapping(address eoa => bytes32 seed) public override nextSeeds;

    /// @inheritdoc IPRBProxyRegistry
    mapping(address owner => IPRBProxy proxy) public override proxies;

    /// @inheritdoc IPRBProxyRegistry
    address public override transientProxyOwner;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Check that the owner does not have a proxy.
    modifier noProxy(address owner) {
        IPRBProxy proxy = proxies[owner];
        if (address(proxy) != address(0)) {
            revert PRBProxyRegistry_OwnerHasProxy(owner, proxy);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyRegistry
    function deploy() external override noProxy(msg.sender) returns (IPRBProxy proxy) {
        proxy = _deploy({ owner: msg.sender });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployFor(address owner) public override noProxy(owner) returns (IPRBProxy proxy) {
        proxy = _deploy(owner);
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployAndExecute(
        address target,
        bytes calldata data
    )
        external
        override
        noProxy(msg.sender)
        returns (IPRBProxy proxy, bytes memory response)
    {
        (proxy, response) = _deployAndExecute({ owner: msg.sender, target: target, data: data });
    }

    /// @inheritdoc IPRBProxyRegistry
    function deployAndExecuteFor(
        address owner,
        address target,
        bytes calldata data
    )
        public
        override
        noProxy(owner)
        returns (IPRBProxy proxy, bytes memory response)
    {
        (proxy, response) = _deployAndExecute(owner, target, data);
    }

    /// @inheritdoc IPRBProxyRegistry
    function transferOwnership(address newOwner) external override noProxy(newOwner) {
        // Check that the caller has a proxy.
        IPRBProxy proxy = proxies[msg.sender];
        if (address(proxy) == address(0)) {
            revert PRBProxyRegistry_OwnerDoesNotHaveProxy({ owner: msg.sender });
        }

        // Delete the proxy for the caller.
        delete proxies[msg.sender];

        // Set the proxy for the new owner.
        proxies[newOwner] = proxy;

        // Transfer the proxy.
        proxy.transferOwnership(newOwner);

        // Log the transfer of the proxy ownership.
        emit TransferOwnership({ proxy: proxy, oldOwner: msg.sender, newOwner: newOwner });
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the public functions that call this internal function.
    function _deploy(address owner) internal returns (IPRBProxy proxy) {
        // Load the next seed.
        bytes32 seed = nextSeeds[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided seed.
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));

        // Deploy the proxy with CREATE2.
        transientProxyOwner = owner;
        proxy = new PRBProxy{ salt: salt }();
        delete transientProxyOwner;

        // Set the proxy for the owner.
        proxies[owner] = proxy;

        // Increment the seed.
        // We're using unchecked arithmetic here because this cannot realistically overflow, ever.
        unchecked {
            nextSeeds[tx.origin] = bytes32(uint256(seed) + 1);
        }

        // Log the proxy via en event.
        // forgefmt: disable-next-line
        emit DeployProxy({
            origin: tx.origin,
            operator: msg.sender,
            owner: owner,
            seed: seed,
            salt: salt,
            proxy: proxy
        });
    }

    /// @dev See the documentation for the public functions that call this internal function.
    function _deployAndExecute(
        address owner,
        address target,
        bytes calldata data
    )
        internal
        returns (IPRBProxy proxy, bytes memory response)
    {
        // Load the next seed.
        bytes32 seed = nextSeeds[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided seed.
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));

        // Deploy the proxy with CREATE2. The registry will temporarily be the owner of the proxy.
        transientProxyOwner = address(this);
        proxy = new PRBProxy{ salt: salt }();
        delete transientProxyOwner;

        // Set the proxy for the owner.
        proxies[owner] = proxy;

        // Increment the seed.
        // We're using unchecked arithmetic here because this cannot realistically overflow, ever.
        unchecked {
            nextSeeds[tx.origin] = bytes32(uint256(seed) + 1);
        }

        // Delegate call to the target contract.
        response = proxy.execute(target, data);

        // Transfer the ownership to the specified owner.
        proxy.transferOwnership(owner);

        // Log the proxy via en event.
        // forgefmt: disable-next-line
        emit DeployProxy({
            origin: tx.origin,
            operator: msg.sender,
            owner: owner,
            seed: seed,
            salt: salt,
            proxy: proxy
        });
    }
}
