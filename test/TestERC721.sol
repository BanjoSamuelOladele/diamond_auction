// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import "../contracts/NFTERC721.sol";

contract TestERC721 is Test{

    NFTERC721 private nft;

    function setUp() external {
        nft = new NFTERC721();
    }

    function testNftTokenName() external {
        string memory result = nft.name();
        console.log("result is here ::: ",result);
        assertEq(result, "wicked token");
    }

    function testMinToAddress() external {
        address owner = address (1);
        nft.mintTo(owner, 111);
        console.log("owner address is :::", owner);
        address result = nft.ownerOf(111);
        assertEq(result, owner);
    }


}
