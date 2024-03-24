pragma solidity ^0.8.0;
//import "@openzeppelin/"

library LibAppStorage {
    struct Layout {
        uint256 currentNo;
        string name;
    }

    struct Auction{
        address owner;
        uint startAt;
        uint endAt;
        bool hasEnded;
        uint highestBid;
        uint secondHighestBid;
        address highestBidder;
        address secondHighestBidder;
        address erc721Address;
        uint tokenId;
    }

    struct AuctionStorage{

        //auction
        mapping(address => uint16) auctionsCounter;
        mapping(address => mapping(uint16 => Auction)) auctions;

        //token
        uint256 totalSupply;
        string symbol;
        string name;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }
}
