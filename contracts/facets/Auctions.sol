// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
import "lib/forge-std/src/console.sol";
import "contracts/interfaces/IERC165.sol";

contract Auctions {
    LibAppStorage.AuctionStorage internal appStorage;

    function createAuction(address _contractAddress, uint _tokenId, string memory auctionName, uint _startingPrice) external{
        bytes4 isErc721OrErc115 =  isACompatibleAddress(_nftAddress);
        require(_startingPrice > 0, "invalid starting amount");
        if(isErc721OrErc115 == LibAppStorage.ERC721_INTERFACE_ID){

        }
        else{

        }
        LibAppStorage.Auction storage auction = appStorage.auctions[msg.sender];
        auction.owner = msg.sender;
        auction.auctionName = auctionName;
        auction.collectionContractAddress = _contractAddress;
        auction.startingAmount = _startingPrice;
        auction.tokenId = _tokenId;
//        auction.startAt = block.timestamp;
    }

    function startAuction() external{

    }

    function transferCollectionToDiamond(bytes4 id, uint _tokenId) internal {
        if(isErc721OrErc115 == LibAppStorage.ERC721_INTERFACE_ID){

        }

    }

    function isACompatibleAddress(address contractAddress) internal view returns(bytes4) {
        bytes4 erc721InterfaceId = LibAppStorage.ERC721_INTERFACE_ID;
        bytes4 erc1155InterfaceId = LibAppStorage.ERC1155_INTERFACE_ID;

        bool isErc721 =  IERC165(contractAddress).supportsInterface(erc721InterfaceId);
        bool isErc1155 = IERC165(contractAddress).supportsInterface(erc1155InterfaceId);
        require(isErc721 || isErc1155, "Not a supported collection contract address");

        return isErc721 ?  erc721InterfaceId : erc1155InterfaceId;
    }

}
