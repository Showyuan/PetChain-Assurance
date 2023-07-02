// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract PetNFT is ERC721 {

    struct Pet {
        uint256 id;     // 晶片ID
        string name;    // 名稱
        string breed;   // 品種
        uint8 age;      // 年齡
        address owner;  // 飼主
    }

    // 晶片ID => 寵物細節
    mapping(uint256 => Pet) private _pets;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
        mintPet 新增一隻寵物
        owner: 飼主地址
        petId: 晶片ID
        name: 名稱
        breed: 品種
        age: 年齡
     */
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

    /**
        transfer 移轉飼主
        newOwner: 新飼主地址
        tokenId: 晶片ID
     */
    function transfer(address newOwner, uint256 tokenId) external {
        safeTransferFrom(msg.sender, newOwner, tokenId, '');
    }

    /**
        getPetInfo 取得寵物資訊
        tokenId: 晶片ID
     */
    function getPetInfo(uint256 petId) external view returns (uint256 id, string memory name, string memory breed, uint8 age, address owner) {
        require(_exists(petId), "Pet does not exist");

        Pet memory pet = _pets[petId];
        return (pet.id, pet.name, pet.breed, pet.age, pet.owner);
    }

    /**
        burn 銷毀寵物資訊
        tokenId: 晶片ID
     */
    function burn(uint256 petId) external {
        _burn(petId);
    }
}
