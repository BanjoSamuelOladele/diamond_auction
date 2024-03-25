// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTERC721 is ERC721("wicked token", "wicT") {
    constructor() {}

    function mintTo(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}
