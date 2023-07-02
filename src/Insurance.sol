// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    struct InsurancePool {
        string animalType;
        string medicalProcedure;
        uint256 coverageAmount;
    }

    mapping(string => InsurancePool) public insurancePools; // poolName => InsurancePool
    mapping(string => mapping(uint256 => bool)) public insurancePetsinPools; // poolName => InsurancePool
    mapping(uint256 => string[]) public insuredPoolsPerPet; // petId => poolName[]

    event InsurancePurchased(uint256 indexed petId, string poolName);
    event InsuranceCancelled(uint256 indexed petId, string poolName);

    function createInsurancePool(string memory _animalType, string memory _medicalProcedure, uint256 _coverageAmount) external returns (string memory _poolName){
        _poolName = string(abi.encodePacked(_animalType, "/", _medicalProcedure));
        require(insurancePools[_poolName].coverageAmount == 0, "Pool already exists");

        InsurancePool memory newPool = InsurancePool({
            animalType: _animalType,
            medicalProcedure: _medicalProcedure,
            coverageAmount: _coverageAmount
        });

        insurancePools[_poolName] = newPool;
    }

    function purchaseInsurance(uint256 petId, string memory poolName) external payable {
        InsurancePool storage pool = insurancePools[poolName];
        require(pool.coverageAmount <= msg.value, "Insufficient payment");
        
        uint256 excessAmount = msg.value - pool.coverageAmount;

        if (excessAmount > 0) {
            payable(msg.sender).transfer(excessAmount); // Return excess amount to msg.sender
        }

        insurancePetsinPools[poolName][petId] = true;
        insuredPoolsPerPet[petId].push(poolName);

        emit InsurancePurchased(petId, poolName);
    }

    function cancelInsurance(uint256 petId, string memory poolName) external {
        require(insuredPoolsPerPet[petId].length > 0, "The pet wasn't insured any  pool");

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

    function getInsurancePool(string memory poolName) external view returns (string memory, string memory, uint256) {
        require(insurancePools[poolName].coverageAmount > 0, "Invalid pool name");

        InsurancePool memory pool = insurancePools[poolName];

        return (pool.animalType, pool.medicalProcedure, pool.coverageAmount);
    }
}