// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import "../contracts/ERC721.sol";

contract TestERC721 is Test{

    NFTERC721 private nft;

    function setUp() external {
        nft = new NFTERC721();
    }

    function testNftTokenName() external {
        string  result = nft.name();

        assertEq(result, "wicked token");
    }
}
