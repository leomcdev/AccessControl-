// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EcrecoverTest is ERC721, AccessControl {
    bytes32 public constant HANDLER = keccak256("HANDLER");
    address sigAddress;

    constructor(address _default_admin_role, address _sigAddress) ERC721("", "") {
        sigAddress = _sigAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, _default_admin_role);
    }
    
   function sigCreate(address _signer, uint _amount, bytes32 _message, uint8 _v, bytes32 _r,
        bytes32 _s) public view {
        bytes memory message = abi.encode(_signer, _amount, _message);
        // bytes memory pre = "\x19Ethereum Signed Message:\n128";
        bytes32 m = keccak256(abi.encodePacked(sigAddress, message));
        require(ecrecover(m, _v, _r, _s) == sigAddress, "Signature invalid");
   }

   function mintAndSigns(uint8 _v, bytes32 _r, bytes32 _s) external onlyRole(HANDLER) {
        bytes memory message = abi.encode(msg.sender);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";            
        bytes32 m = keccak256(abi.encodePacked(prefix, message));

        require(ecrecover(m, _v, _r, _s) == sigAddress, "Signature invalid");
        _mint(msg.sender, 1);
   }

    
    function mint(address _to, uint _tokenId) external onlyRole(HANDLER){
        _safeMint(_to, _tokenId);
    }

    function tokenPrefix (uint _type) external pure returns (uint){
        return _type * (10**6);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    } 
}

