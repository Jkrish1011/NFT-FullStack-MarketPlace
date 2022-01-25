//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// for security purpose(abstains from multiple transaction attempts, security while interacting with other contracts etc)
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    // To track each item in the market
    Counters.Counter private _itemIds;
    // To track each item sold in the market.
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor() {
        // Owner is the person deploying this contract
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    // TokenId -> MarketItem
    mapping(uint256 => MarketItem) private idToMarketItem;

    // to emit an event when a market item is created.
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // A function to just view/get what the listing price is, in the market.
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // To create market item and putting for sale.
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be atleast 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to the listing price"
        );
        _itemIds.increment();
        // item id for the nft going in for sale right now.
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)), // Owner - setting it as empty because its not sold yet!
            price,
            false
        );
        // Transferring the ownership of NFT to contract itself. because contract is going to transfer it to next buyer.
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    }

    // To create a sale (buy/sell)
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        // To verify if the buyer is giving the stated amount for the NFT
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchage"
        );
        // Transfer the amount to the seller.
        idToMarketItem[itemId].seller.transfer(msg.value);
        // Transfer owner to the buyer of the NFT.
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        // Set the local value for the owner
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        // Increment items sold
        _itemsSold.increment();
        // Pay owner of the contract
        payable(owner).transfer(listingPrice);
    }

    // To fetch those items that are not sold.
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        // Logic to get all items that are not yet sold.
        for (uint256 index = 0; index < itemCount; index++) {
            if (idToMarketItem[index + 1].owner == address(0)) {
                uint256 currentId = idToMarketItem[index + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // To fetch items that user purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 index = 0; index < totalItemCount; index++) {
            if (idToMarketItem[index + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 index = 0; index < totalItemCount; index++) {
            if (idToMarketItem[index + 1].owner == msg.sender) {
                uint256 currentId = idToMarketItem[index + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // get items that a user created.
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 index = 0; index < totalItemCount; index++) {
            if (idToMarketItem[index + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 index = 0; index < totalItemCount; index++) {
            if (idToMarketItem[index + 1].seller == msg.sender) {
                // Get current Item
                uint256 currentId = idToMarketItem[index + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
