// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAssetState {
    
    function mint(address _to, uint _tokenId) external;
    function getAssetGroup (uint _tokenId, uint _assetGroupId) external view;
    function tokenPrefix (uint _type) external pure returns (uint);

    function mintFromGroup(address _to, uint _tokenId, uint _groupId) external;

}