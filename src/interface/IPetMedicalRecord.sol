// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPetMedicalRecord {
    function addMedicalRecord(uint256 petId, string memory record, string memory diseaseName, uint256 medicalExpenses) external returns (string memory id);
    function getMedicalRecordsCount(uint256 petId) external view returns (uint256);
    function getMedicalRecord(uint256 petId, uint256 index) external view returns (uint256, string memory, string memory, string memory, uint256, uint256, bool);
}