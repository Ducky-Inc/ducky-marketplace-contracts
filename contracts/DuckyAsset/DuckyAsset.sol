// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";

import "../../node_modules/@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol";
import "./DuckyAssetLib.sol";

contract DuckyAsset is LSP8IdentifiableDigitalAsset {
    // Trait controller UP or EOA - can add perks
    address public traitController;

    constructor(
        address owner
    ) LSP8IdentifiableDigitalAsset("DuckyNFAsset", "NFA", owner, 4) {}

    //  Event to indicate that a refresh is required by the client or server
    event RefreshRequired(string jsonData);

    // Validates if a perk already exists
    function validatePerkNotExists(bytes32 perkKey) internal view {
        require(
            _getData(perkKey).length == 0,
            "DuckyAsset: Perk already exists"
        );
    }

    // Modifier to check if the caller is the trait controller
    modifier onlyTraitController() {
        require(
            msg.sender == traitController,
            "DuckyAsset: Caller is not the trait controller"
        );
        _;
    }

    function setTraitController(address _traitController) public onlyOwner {
        traitController = _traitController;
    }

    // Add a redeemable perk
    function addPerk(
        address assetAddress,
        string memory perkName,
        string memory metadataURI,
        bytes32[] memory perkKeys, //  perkKeys: ['0xc5153e804d7db642331bd993e591958fe09afe22884c67679daf532c46c390ee'],
        string[] memory perkProperties //  perkProperties: [ '[{"redeemed":false}]' ]
    ) public onlyTraitController {
        require(
            perkKeys.length == perkProperties.length,
            "Keys and properties length mismatch"
        );

        // Loop through perkKeys and perkProperties to encode and set data
        for (uint i = 0; i < perkKeys.length; i++) {
            _setData(perkKeys[i], abi.encode(perkProperties[i]));
            string memory jsonData = prepareJsonData(
                "PerkAdded",
                assetAddress,
                perkName,
                perkKeys[i]
            );
            emit RefreshRequired(jsonData);
        }

        // Encode and set the metadata URI using the root key for the perk
        bytes32 metadataKey = keccak256(
            abi.encodePacked("Perks:", assetAddress, ":", perkName, ":Metadata")
        );
        _setData(metadataKey, abi.encode(metadataURI));

        string memory jsonData = prepareJsonData(
            "MetadataUpdated",
            assetAddress,
            perkName,
            metadataKey
        );

        // Emit an event indicating that a perk has been added or updated
        emit RefreshRequired(jsonData);
    }

    // //Require the perk to not already exist
    // // Generate dynamic keys for each aspect of the perk
    // bytes32 metadataKey = DuckyAssetLib.generatePerkKey(
    //     assetAddress,
    //     perkName,
    //     "PerkMetadata"
    // ); // returns Perk:<assetAddress>:<perkName>:Metadata

    // bytes32 redeemedKey = DuckyAssetLib.generatePerkKey(
    //     assetAddress,
    //     perkName,
    //     "Redeemed"
    // );
    // bytes32 fulfilledKey = DuckyAssetLib.generatePerkKey(
    //     assetAddress,
    //     perkName,
    //     "Fulfilled"
    // );

    // validatePerkNotExists(redeemedKey);
    // // Encode the perk data using LSP2 Schema, store in storage, emit event
    // // Store the data in storage
    // _setData(metadataKey, abi.encode(metadataURI));
    // _setData(redeemedKey, abi.encode(false)); // set redeemed to false
    // _setData(fulfilledKey, abi.encode(false)); // set fulfilled to false

    // emit RefreshRequired("PerkAdded", metadataKey);
    // }

    // function getAllPerks(
    //     address assetAddress
    // ) public pure returns (bytes32[] memory) {
    //     bytes32[] memory perkKeys = new bytes32[](4);
    //     perkKeys[0] = DuckyAssetLib.generatePerkKey(
    //         assetAddress,
    //         "Perk1",
    //         "PerkMetadata"
    //     );
    //     perkKeys[1] = DuckyAssetLib.generatePerkKey(
    //         assetAddress,
    //         "Perk2",
    //         "PerkMetadata"
    //     );
    //     perkKeys[2] = DuckyAssetLib.generatePerkKey(
    //         assetAddress,
    //         "Perk3",
    //         "PerkMetadata"
    //     );
    //     perkKeys[3] = DuckyAssetLib.generatePerkKey(
    //         assetAddress,
    //         "Perk4",
    //         "PerkMetadata"
    //     );
    //     return perkKeys;
    // }

    // Helper function to prepare JSON data
    function prepareJsonData(
        string memory action,
        address assetAddress,
        string memory perkName,
        bytes32 key
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"action":"',
                    action,
                    '", "assetAddress":"',
                    Strings.toHexString(assetAddress),
                    '", "perkName":"',
                    perkName,
                    '", "key":"',
                    Strings.toHexString(uint256(key), 32),
                    '"}'
                )
            );
    }

    // // Helper function to convert string to bytes32
    // function stringToBytes32(
    //     string memory source
    // ) internal pure returns (bytes32 result) {
    //     bytes memory tempEmptyStringTest = bytes(source);
    //     if (tempEmptyStringTest.length == 0) {
    //         return 0x0;
    //     }

    //     assembly {
    //         result := mload(add(source, 32))
    //     }
    // }
}
