// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IDiamondCut} from "../contracts/interfaces/IDiamondCut.sol";
import "lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/facets/Auctions.sol";
import "../contracts/NFTERC721.sol";
import "lib/forge-std/src/console.sol";
import "../contracts/DERC1155.sol";

contract TestAuction is Test, IDiamondCut{
    Diamond private diamond;
    DiamondCutFacet private dCutFacet;
    DiamondLoupeFacet private dLoupe;
    OwnershipFacet private ownerF;
    ERC20Facet private erc20Facet;
    Auctions private auctions;
    NFTERC721 private firstNFT;

    address private A = address(0xa);
    address private B = address(0xb);

    Auctions private interactingAuction;
    ERC20Facet private facetErc20;
    DERC1155 private erc1155;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Facet = new ERC20Facet();
        auctions = new Auctions();
        firstNFT = new NFTERC721();
        erc1155 = new DERC1155();

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
            facetAddress: address(dLoupe),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondLoupeFacet")
        })
        );

        cut[1] = (
            FacetCut({
            facetAddress: address(ownerF),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("OwnershipFacet")
        })
        );
        cut[2] = (
            FacetCut({
            facetAddress: address(auctions),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("Auctions")
        })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        A = mkaddr("staker a");
        B = mkaddr("staker b");

        interactingAuction = Auctions(address(diamond));
    }

    function testGetIfItIsAValidErc721() external{
       bool result =  interactingAuction.isACompatibleAddress(address(erc1155));
        assertTrue(result);
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
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

    function diamondCut(
        FacetCut[] memory _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
