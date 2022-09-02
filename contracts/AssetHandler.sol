// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interfaces/IAssetState.sol";

contract AssetHandler is ERC721, AccessControl {
    IAssetState IS;
    mapping (uint256 => string) private _tokenURIs;
    mapping(uint256 => mapping(uint256 => uint256)) public assetGroup;
    mapping (uint => uint) nextId; //gruppid => nextId
    mapping (uint => bool) check;
    bytes32 public constant MINTER = keccak256("MINTER");
 
    constructor(address _default_admin_role, IAssetState _IS) ERC721("Immotoken", "IMO") {
        IS = _IS;
        _setupRole(DEFAULT_ADMIN_ROLE, _default_admin_role);
    }

    function getAssetGroup(uint _tokenId) external view onlyRole(MINTER) returns (uint) {
        return _tokenId / 1000000;
    }

    // // give token 1000000, set assetgroup to 1,
    // // mint token and give next token 1000001
    // function mintInGroup(address _to, uint[] memory _assetGroups) external onlyRole(MINTER) {
        
    //     uint _groupId;
    //     assetGroup[_groupId++];
    //     nextId[_groupId];
    //     uint _token = IS.tokenPrefix(_groupId) + nextId[_groupId]; 
    //     _assetGroups[_token];
    //     IS.mint(_to, _token);
    // }


    // give token 1000000, set assetgroup to 1,
    // mint token and give next token 1000001
    function mintInGroup(address _to, uint _groupId) external onlyRole(MINTER) {
        nextId[_groupId]++;
        uint _token = IS.tokenPrefix(_groupId) + nextId[_groupId]; 
        IS.mint(_to, _token);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        return _tokenURIs[_tokenId];
    }
}
