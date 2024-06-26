// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/ERC20Facet.sol";

contract TestERC20Facet is Test, IDiamondCut {
    Diamond private diamond;
    DiamondCutFacet private dCutFacet;
    DiamondLoupeFacet private dLoupe;
    OwnershipFacet private ownerF;
    ERC20Facet private erc20Facet;

    address private A = address(0xa);
    address private B = address(0xb);

    ERC20Facet private diamondErc20;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Facet = new ERC20Facet();

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
                facetAddress: address(erc20Facet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        A = mkaddr("staker a");
        B = mkaddr("staker b");

        //mint test tokens
        ERC20Facet(address(diamond)).mintTo(A);
        ERC20Facet(address(diamond)).mintTo(B);

        diamondErc20 = ERC20Facet(address(diamond));
    }

    function testMintToAddressesBalance() external {
        assertEq(diamondErc20.balanceOf(A), 100_000_000e18);
        assertEq(diamondErc20.balanceOf(B), 100_000_000e18);
    }

    function testTransfer() external {
        switchSigner(A);
        diamondErc20.transfer(address(1), 50_000e18);
        assertEq(diamondErc20.balanceOf(address(1)), 50_000e18);
        assertEq(diamondErc20.balanceOf(A), 99_950_000e18);
    }

    function testApprove() external {
        switchSigner(A);
        diamondErc20.approve(address(1), 100_000e18);
        uint256 result = diamondErc20.allowance(A, address(1));
        assertEq(result, 100_000e18);
    }

    function testTransferFrom() external {
        switchSigner(A);
        diamondErc20.approve(address(1), 100_000e18);
        switchSigner(address(1));
        diamondErc20.transferFrom(A, address(3), 80_000e18);
        assertEq(diamondErc20.balanceOf(address(3)), 80_000e18);
        assertEq(diamondErc20.allowance(A, address(1)), 20_000e18);
        assertEq(diamondErc20.balanceOf(A), 99_920_000e18);
    }

    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
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

    function diamondCut(FacetCut[] memory _diamondCut, address _init, bytes calldata _calldata) external override {}
}
