const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create and execute Market sales of NFT", async function () {

    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();
    console.log(listingPrice)
    
    const auctionPrice = ethers.utils.parseUnits('100', 'ether');

    await nft.createToken("https://www.mytokenlocation.com");
    await nft.createToken("https://www.mytokenlocation2.com");

    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {value: listingPrice});
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {value: listingPrice});

    //get test accounts from ethers.
    const[firstCreator, buyerAddress, thirdAddress, fourthAddress] = await ethers.getSigners();
    
    console.log(firstCreator.address)
    console.log(buyerAddress.address)
    console.log(thirdAddress.address)
    // create sale
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value: auctionPrice});    
    
    await market.connect(thirdAddress).createMarketSale(nftContractAddress, 2, {value: auctionPrice});    
    
    const items = await market.fetchMarketItems();
    console.log('items: ', items);

    const itemsMyNFTs = await market.connect(buyerAddress).fetchMyNFTs();
    console.log('itemsMyNFTs : ', itemsMyNFTs);

    const itemsMyNFTs2 = await market.connect(thirdAddress).fetchMyNFTs();
    console.log('itemsMyNFTs2 : ', itemsMyNFTs2);

    //const itemsMyNFTsCreated = await market.fetchItemsCreated();
    const itemsMyNFTsCreated = await market.connect(firstCreator).fetchItemsCreated();
    console.log('itemsMyNFTsCreated : ', itemsMyNFTsCreated);
  });
});
