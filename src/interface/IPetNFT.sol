// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPetNFT {
    function mintPet(address owner, uint256 petId, string memory name, string memory breed, uint8 age) external;
    function transfer(address newOwner, uint256 tokenId) external;
    function getPetInfo(uint256 petId) external view returns (uint256 id, string memory name, string memory breed, uint8 age, address owner);
    function burn(uint256 petId) external;
}