pragma solidity ^0.8.0;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

contract LayoutChangerFacet {
    LibAppStorage.Layout layout;

    function ChangeNameAndNo(uint256 _newNo, string memory _newName) external {
        layout.currentNo = _newNo;
        layout.name = _newName;
    }

    function getLayout() public view returns (LibAppStorage.Layout memory l) {
        l.currentNo = layout.currentNo;
        l.name = layout.name;
    }
}
