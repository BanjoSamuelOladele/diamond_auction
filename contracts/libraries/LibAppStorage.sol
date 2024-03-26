pragma solidity ^0.8.0;
//import "@openzeppelin/"

library LibAppStorage {
    event Transfer(address, address, uint256);

    struct Layout {
        uint256 currentNo;
        string name;
    }

    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;
    bytes4 internal constant ERC1155_INTERFACE_ID = 0xd9b67a26;

    function appStorageLocation() internal pure returns (AuctionStorage storage app) {
        assembly {
            app.slot := 0
        }
    }

    function _transferFrom(address _from, address _to, uint256 _amount) internal {
        AuctionStorage storage l = appStorageLocation();
        uint256 frombalances = l.balances[_from];
        require(frombalances >= _amount, "ERC20: Not enough tokens to transfer");
        l.balances[_from] = frombalances - _amount;
        l.balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    struct Bidder {
        uint256 amount;
        uint[] timeInteraction;
    }

    struct Auction {
        string auctionName;
        address owner;
        uint256 startAt;
        uint256 endAt;
        bool hasEnded;
        uint256 highestBid;
        uint256 secondHighestBid;
        address highestBidder;
        address secondHighestBidder;
        uint256 startingAmount;
        address collectionContractAddress;
        uint256 tokenId;
        bool hasStarted;
        bool isCanceled;
//        mapping(address => Bidder) bidders;
    }

    struct AuctionStorage {
        //auction
        //        mapping(address => uint16) auctionsCounter;
        mapping(address => Auction[]) auctions;
        Auction[] listOfAuctions;
        //token
        uint256 totalSupply;
        string symbol;
        string name;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }
}
