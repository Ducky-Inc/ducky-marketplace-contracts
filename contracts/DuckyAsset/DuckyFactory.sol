// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./DuckyAsset.sol";

contract DuckyAssetFactory {
    event AssetCreated(address indexed assetAddress);

    function createDuckyAsset(
        string memory name,
        string memory symbol,
        address traitController
    ) public returns (address) {
        DuckyAsset newAsset = new DuckyAsset(
            name,
            symbol,
            msg.sender,
            traitController
        );
        emit AssetCreated(address(newAsset));
        return address(newAsset);
    }
}
