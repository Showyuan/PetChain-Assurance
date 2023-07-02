// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract PetNFT is ERC721 {

    struct Pet {
        uint256 id;
        string name;
        string breed;
        uint8 age;
        address owner;
    }

    // Mapping owner address to pet
    mapping(uint256 => Pet) private _pets;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function mintPet(address owner, uint256 petId, string memory name, string memory breed, uint8 age) external {
        _safeMint(owner, petId);

        Pet memory newPet = Pet({
            id: petId,
            name: name,
            breed: breed,
            age: age,
            owner: owner
        });
        _pets[petId] = newPet;

    }

    function transfer(address newOwner, uint256 tokenId) external {
        safeTransferFrom(msg.sender, newOwner, tokenId, '');
    }

    function getPetInfo(uint256 petId) external view returns (uint256 id, string memory name, string memory breed, uint8 age, address owner) {
        require(_exists(petId), "Pet does not exist");

        Pet memory pet = _pets[petId];
        return (pet.id, pet.name, pet.breed, pet.age, pet.owner);
    }

    function burn(uint256 petId) external {
        _burn(petId);
    }
}
