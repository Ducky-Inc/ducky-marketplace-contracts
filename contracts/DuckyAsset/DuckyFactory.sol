// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./DuckyAsset.sol";

contract DuckyAssetFactory {
    event AssetCreated(address indexed assetAddress);

    function createDuckyAsset() public returns (address) {
        DuckyAsset newAsset = new DuckyAsset(msg.sender);
        emit AssetCreated(address(newAsset));
        return address(newAsset);
    }
}
