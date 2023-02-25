// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyFactory } from "./interfaces/IPRBProxyFactory.sol";
import { PRBProxy } from "./PRBProxy.sol";

/// @title PRBProxyFactory
/// @dev This contract implements the {IPRBProxyFactory} interface.
contract PRBProxyFactory is IPRBProxyFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyFactory
    uint256 public constant override VERSION = 3;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Internal mapping to track all deployed proxies.
    mapping(IPRBProxy proxy => bool deployed) internal proxies;

    /// @dev Internal mapping to track the next seed to be used by an EOA.
    mapping(address eoa => bytes32 seed) internal nextSeeds;

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyFactory
    function getNextSeed(address eoa) external view override returns (bytes32 nextSeed) {
        nextSeed = nextSeeds[eoa];
    }

    /// @inheritdoc IPRBProxyFactory
    function isProxy(IPRBProxy proxy) external view override returns (bool result) {
        result = proxies[proxy];
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxyFactory
    function deploy() external override returns (IPRBProxy proxy) {
        proxy = deployFor({ owner: msg.sender });
    }

    /// @inheritdoc IPRBProxyFactory
    function deployFor(address owner) public override returns (IPRBProxy proxy) {
        // Deploy the proxy.
        proxy = _deploy(owner);

        // Transfer the ownership from this factory contract to the specified owner.
        proxy.transferOwnership(owner);
    }

    /// @inheritdoc IPRBProxyFactory
    function deployAndExecute(
        address target,
        bytes calldata data
    )
        external
        override
        returns (IPRBProxy proxy, bytes memory response)
    {
        (proxy, response) = deployAndExecuteFor({ owner: msg.sender, target: target, data: data });
    }

    /// @inheritdoc IPRBProxyFactory
    function deployAndExecuteFor(
        address owner,
        address target,
        bytes calldata data
    )
        public
        override
        returns (IPRBProxy proxy, bytes memory response)
    {
        // Deploy the proxy.
        proxy = _deploy(owner);

        // Delegate call to the target contract.
        response = proxy.execute(target, data);

        // Transfer the ownership from this factory contract to the specified owner.
        IPRBProxy(proxy).transferOwnership(owner);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the public functions that call this internal function.
    function _deploy(address owner) internal returns (IPRBProxy proxy) {
        bytes32 seed = nextSeeds[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided seed.
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));

        // Deploy the proxy with CREATE2.
        proxy = new PRBProxy{ salt: salt }();

        // Mark the proxy as deployed.
        proxies[proxy] = true;

        // Increment the seed.
        // We're using unchecked arithmetic here because this cannot realistically overflow, ever.
        unchecked {
            nextSeeds[tx.origin] = bytes32(uint256(seed) + 1);
        }

        // Log the proxy via en event.
        // forgefmt: disable-next-line
        emit DeployProxy({
            origin: tx.origin,
            deployer: msg.sender,
            owner: owner,
            seed: seed,
            salt: salt,
            proxy: proxy
        });
    }
}
