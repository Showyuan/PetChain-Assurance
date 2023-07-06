// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IInsurance {
    function createInsurancePool(string memory _animalType, string memory _medicalProcedure, uint256 _coverageAmount) external returns (string memory _poolName);
    function purchaseInsurance(uint256 petId, string memory poolName) external payable;
    function cancelInsurance(uint256 petId, string memory poolName) external;
    function getInsurancePool(string memory poolName) external view returns (string memory, string memory, uint256);
    function getExpireTime(uint256 petId, string memory poolName) external view returns (uint256);
}