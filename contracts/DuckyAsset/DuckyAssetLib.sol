// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library DuckyAssetLib {
    // Helper function to generate dynamic perk keys
    // - @dev use to nest properties under a perk key in the storage map
    // - @param assetAddress - address of the LSP8 Minted Asset controlled by this contract
    // - @param perkName - name of the perk to generate the key for
    function generatePerkKey(
        address assetAddress,
        string memory perkName,
        string memory propertyName
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "Perks:",
                    assetAddress,
                    ":",
                    perkName,
                    ":",
                    propertyName
                )
            );
    }
}
