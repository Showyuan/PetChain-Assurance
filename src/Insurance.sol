// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IPetNFT} from "./interface/IPetNFT.sol";
import {IToken} from "./interface/IToken.sol";
import {IReserveFund} from "./interface/IReserveFund.sol";

contract Insurance {

    address private PET_NFT_ADDR;
    address private PET_TOKEN_ADDR;
    address private RESERVE_FUND_ADDR;

    struct InsurancePool {
        string animalType;         // 寵物類型
        string medicalProcedure;   // 醫療保障項目
        uint256 coverageAmount;    // 保費
    }

    // 保險名稱 => Pool內容
    mapping(string => InsurancePool) public insurancePools;
    // 保險名稱 => (寵物晶片ID => 是否投保)
    mapping(string => mapping(uint256 => bool)) public insurancePetsinPools;
    // 寵物晶片ID => 投保項目
    mapping(uint256 => string[]) public insuredPoolsPerPet;
    // 寵物晶片ID => (投保項目 => 保險到期日)
    mapping(uint256 =>  mapping(string => uint256)) public insuredTimeStamp;


    event InsurancePurchased(uint256 indexed petId, string poolName);
    event InsuranceCancelled(uint256 indexed petId, string poolName);
    event InsuranceRenewed(uint256 indexed petId, string poolName);

    constructor(address petNft, address petToken, address reserveFund) {
        PET_NFT_ADDR = petNft;
        PET_TOKEN_ADDR = petToken;
        RESERVE_FUND_ADDR = reserveFund;
    }

    /**
        createInsurancePool 新增保險項目
        _animalType: 寵物類型
        _medicalProcedure: 醫療保障項目
        _coverageAmount: 保費
     */
    function createInsurancePool(string memory _animalType, string memory _medicalProcedure, uint256 _coverageAmount) external returns (string memory _poolName){
        _poolName = string(abi.encodePacked(_animalType, "/", _medicalProcedure));
        require(IReserveFund(RESERVE_FUND_ADDR).getReserveBalance(_poolName) == 0, "Pool already exists");

        InsurancePool memory newPool = InsurancePool({
            animalType: _animalType,
            medicalProcedure: _medicalProcedure,
            coverageAmount: _coverageAmount
        });

        insurancePools[_poolName] = newPool;
    }

    /**
        purchaseInsurance 購買保險
        petId: 寵物晶片ID
        poolName: 保險名稱
     */
    function purchaseInsurance(uint256 petId, string memory poolName) external payable {
        (,,,, address owner) = IPetNFT(PET_NFT_ADDR).getPetInfo(petId);
        require(owner == msg.sender, "You aren't the pet's owner");

        InsurancePool storage pool = insurancePools[poolName];
        require(pool.coverageAmount <= msg.value, "Insufficient payment");
        
        uint256 excessAmount = msg.value - pool.coverageAmount;
        if (excessAmount > 0) {
            payable(msg.sender).transfer(excessAmount); // Return excess amount to msg.sender
        }

        insurancePetsinPools[poolName][petId] = true;
        insuredPoolsPerPet[petId].push(poolName);
        insuredTimeStamp[petId][poolName] = block.timestamp + 365 days;

        IReserveFund(RESERVE_FUND_ADDR).depositFunds{value: msg.value}(poolName);
        IToken(PET_TOKEN_ADDR).mint(owner, 1 * 10 ** IToken(PET_TOKEN_ADDR).getDecimals());

        emit InsurancePurchased(petId, poolName);
    }
    
    /**
        cancelInsurance 拒保/退保
        petId: 寵物晶片ID
        poolName: 保險名稱
     */
    function cancelInsurance(uint256 petId, string memory poolName) external {
        require(insuredPoolsPerPet[petId].length > 0, "The pet wasn't insured any pool");

        // Remove petId from the insurancePetsinPools array of the pool
        insurancePetsinPools[poolName][petId] = false;

        // Remove poolName from the insuredPoolsPerPet array of the pet
        string[] storage poolIndexes = insuredPoolsPerPet[petId];
        for (uint256 i = 0; i < poolIndexes.length; i++) {
            if (keccak256(bytes(poolName)) == keccak256(bytes(poolIndexes[i]))) {
                poolIndexes[i] = poolIndexes[poolIndexes.length - 1];
                poolIndexes.pop();
                break;
            }
        }

        emit InsuranceCancelled(petId, poolName);
    }

    /**
        getInsurancePool 取得保險內容
        poolName: 保險名稱
     */
    function getInsurancePool(string memory poolName) external view returns (string memory, string memory, uint256) {
        require(insurancePools[poolName].coverageAmount > 0, "Invalid pool name");

        InsurancePool memory pool = insurancePools[poolName];

        return (pool.animalType, pool.medicalProcedure, pool.coverageAmount);
    }

    /**
        getExpireTime 取得保險到期日
        petId: 寵物晶片ID
        poolName: 保險名稱
     */
    function getExpireTime(uint256 petId, string memory poolName) external view returns (uint256) {
        require(insurancePetsinPools[poolName][petId], "The pet wasn't insured the pool");
        return insuredTimeStamp[petId][poolName];
    }

    // todo: expiration
    function checkExpiration(uint256 petId, string memory poolName) external returns (bool){
        
    }
}