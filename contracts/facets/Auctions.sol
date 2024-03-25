// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "lib/forge-std/src/console.sol";
import "contracts/interfaces/IERC165.sol";
import "contracts/interfaces/IERC721.sol";

contract Auctions {
    LibAppStorage.AuctionStorage internal appStorage;

    event AuctionCreatedSuccessfully(address indexed, uint256);
    event StartedAuction(address owner, uint startedTime);
    event EndedAuction(address owner, uint endtime);

    function createAuction(
        address _contractAddress,
        uint256 _tokenId,
        string memory auctionName,
        uint256 _startingPrice
    ) external {
        bytes4 erc721OrErc115 = isACompatibleContractAddress(_contractAddress);
        require(_startingPrice > 0, "invalid starting amount");
        bool isTransferSuccessful = transferCollectionToDiamond(_contractAddress, erc721OrErc115, _tokenId, msg.sender);
        if (isTransferSuccessful) {
            LibAppStorage.Auction memory auction;
            auction.owner = msg.sender;
            auction.auctionName = auctionName;
            auction.collectionContractAddress = _contractAddress;
            auction.startingAmount = _startingPrice;
            auction.tokenId = _tokenId;
            appStorage.auctions[msg.sender].push(auction);
            appStorage.listOfAuctions.push(auction);
            emit AuctionCreatedSuccessfully(msg.sender, _tokenId);
        } else {
            revert();
        }
    }

    function startAuction(uint256 index) external {
        LibAppStorage.Auction storage auction = appStorage.auctions[msg.sender][index];
        require(auction.owner == msg.sender, "only owner can start auction");
        require(!auction.hasStarted, "auction already started");
        auction.startAt = block.timestamp;
        auction.endAt = block.timestamp + 60 minutes;
        auction.hasStarted = true;
        emit StartedAuction(auction.owner, auction.startAt);
    }

    function endAuction(uint index) external{
        LibAppStorage.Auction storage auction = appStorage.auctions[msg.sender][index];
        require(auction.owner == msg.sender, "only owner can perform this action");
        require(!auction.hasEnded, "auction already ended");
//        require(auction.hasStarted, "not started");
        auction.hasEnded = true;
        auction.endAt = block.timestamp;
        emit EndedAuction(auction.owner, auction.endAt);
    }

    function getAuction(uint256 index) external view returns(LibAppStorage.Auction memory){
        return appStorage.listOfAuctions[index];
    }

    function getUserAuctions() external view returns (LibAppStorage.Auction[] memory){
        return appStorage.auctions[msg.sender];
    }

    function transferCollectionToDiamond(address _contractAddress, bytes4 id, uint256 _tokenId, address owner)
    internal
    returns (bool success)
    {
        if (id == LibAppStorage.ERC721_INTERFACE_ID) {
//               IERC721(_contractAddress).approve(address(this), _tokenId);
            IERC721(_contractAddress).transferFrom(owner, address(this), _tokenId);
            success = true;
        } else {}
    }

    function isACompatibleContractAddress(address contractAddress) internal view returns (bytes4) {
        bytes4 erc721InterfaceId = LibAppStorage.ERC721_INTERFACE_ID;
        bytes4 erc1155InterfaceId = LibAppStorage.ERC1155_INTERFACE_ID;

        bool isErc721 = IERC165(contractAddress).supportsInterface(erc721InterfaceId);
        bool isErc1155;
        if(!isErc721){
            isErc1155 = IERC165(contractAddress).supportsInterface(erc1155InterfaceId);
        }
        require(isErc721 || isErc1155, "Not a supported collection contract address");

            //        return isErc721 ? erc721InterfaceId : isErc1155 ? erc1155InterfaceId : bytes(0);
        return isErc721 ? erc721InterfaceId : erc1155InterfaceId;
    }
}
