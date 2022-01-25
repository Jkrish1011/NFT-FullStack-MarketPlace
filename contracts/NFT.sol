//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    /* To keep track of a unique identifier for each token
     * It will help keep track by giving first NFT an ID of 1, second NFT id of 2 and so on.
     */
    Counters.Counter private _tokenIds;

    // Address of the market place with which the NFTs are going to be interacting with. vis-a-vis.
    address contractAddress;

    constructor(address marketPlaceAddress) ERC721("SecretTokens", "SECT") {
        contractAddress = marketPlaceAddress;
    }

    // for minting new tokens
    function createToken(string memory tokenURI) public returns (uint256) {
        // increment and take the latest tokenId for the current NFT to be minted.
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        _setTokenURI(newItemId, tokenURI); //made available from ERC721URIStorage.sol
        setApprovalForAll(contractAddress, true); // give the market place to transfer the tokens between users.

        /* returning the ID to have a handle to this NFT minted for further transfer/ or
         * to execute any other transactions on top of this.
         */
        return newItemId;
    }
}
