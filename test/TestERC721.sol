// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import "../contracts/NFTERC721.sol";

contract TestERC721 is Test{

    NFTERC721 private nft;

    address private A = address(0xa);
    address private B = address(0xb);

    function setUp() external {
        nft = new NFTERC721();

        A = mkaddr("staker a");
        B = mkaddr("staker b");
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

    function testApprove() external {
        nft.mintTo(A, 1111);
        switchSigner(A);
        nft.approve(B, 1111);
        address result = nft.getApproved(1111);
        assertEq(result, B);
        switchSigner(B);
        nft.safeTransferFrom(A, address (3), 1111);
        address newOwner = nft.ownerOf(1111);
        assertEq(newOwner, address (3));
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }



    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }

}
