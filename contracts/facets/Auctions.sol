// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token";
import "lib/forge-std/src/console.sol";
import "contracts/interfaces/IERC165.sol";

contract Auctions {
    LibAppStorage.AuctionStorage internal appStorage;

    function createAuction() external{

    }

    function isACompatibleAddress(address contractAddress) external view returns(bool) {
        bytes4 erc721InterfaceId = 0x80ac58cd;
        bytes4 erc1155InterfaceId = 0xd9b67a26;

        bool isErc721 =  IERC165(contractAddress).supportsInterface(erc721InterfaceId);
        bool isErc1155 = IERC165(contractAddress).supportsInterface(erc1155InterfaceId);

        require(isErc721 || isErc1155, "Not erc721 nor erc1155 ");

        return isErc721 || isErc1155;
    }

}
