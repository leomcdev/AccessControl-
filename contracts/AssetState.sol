// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AssetState is ERC721, AccessControl {
    bytes32 public constant HANDLER = keccak256("HANDLER");
    mapping (uint256 => string) private _tokenURIs;

    //gruppid => nextTokenId
    mapping(uint => uint) public id;
    uint assetGroupCount;
    mapping (uint => uint) public group;

    constructor(address _default_admin_role) ERC721("", "") {
        _setupRole(DEFAULT_ADMIN_ROLE, _default_admin_role);
    }

    // // give the token its id, assetgroup and + ?assetgroupcount?
    // function mint(address _to, uint[] memory allAssetGroups) external onlyRole(HANDLER) {
    //     for (uint i = 0; i < allAssetGroups.length; i++) {
    //         uint token = tokenPrefix(allAssetGroups[i]);
    //         _safeMint(_to, token); 
    //         id[allAssetGroups[i]]++;
    //     }
    // }
    
    function mint(address _to, uint _tokenId) external onlyRole(HANDLER){
        _safeMint(_to, _tokenId);
    }

    function getAssetGroup(uint _groupId) external pure returns (uint) {
        return _groupId;
    }

    // // get the assetgroup the token is in
    // function getAssetGroup (uint _tokenId, uint _assetGroupId, uint[] memory allAssetGroups) external view onlyRole(HANDLER) returns (uint) {
    //     for (uint256 i = 0; i < allAssetGroups.length; i++) {
    //         require(allAssetGroups[i] < assetGroupCount, 'no ids exist');
    //         if (id[_assetGroupId] == _tokenId) {
    //             return _assetGroupId;
    //         }
    //     } 
    // }

    // 1000000
    function tokenPrefix (uint _type) external pure returns (uint){
        return _type * (10**6);
    }

    

    // function getMessageHash(address _to, uint _amount, string memory _message, uint _nonce
    //     )
    //     public pure returns (bytes32) 
    //     { 
    //         return keccak(256(abi.encodePacked(_to, _amount, _message, _nonce));
    //     }
    //     function getEthSignedMessageHash(bytes32 _messageHash) 
    //        public pure returns (bytes32)  

    // }

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

