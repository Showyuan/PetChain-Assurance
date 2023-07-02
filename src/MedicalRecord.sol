// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract PetHospital {
    struct MedicalRecord {
        uint256 petId;
        string medicalId;
        string record;
        string diseaseName;
        uint256 medicalExpenses;
        uint256 timestamp;
    }

    mapping(uint256 => MedicalRecord[]) public _medicalRecords;

    event MedicalRecordAdded(uint256 indexed petId, string indexed medicalId, string diseaseName, uint256 timestamp);

    function addMedicalRecord(uint256 petId, string memory record, string memory diseaseName, uint256 medicalExpenses) external returns (string memory id){
        id = string(abi.encodePacked(petId,_medicalRecords[petId].length));

        MedicalRecord memory newRecord = MedicalRecord({
            petId: petId,
            medicalId: id,
            record: record,
            diseaseName: diseaseName,
            medicalExpenses: medicalExpenses,
            timestamp: block.timestamp
        });

        _medicalRecords[petId].push(newRecord);

        emit MedicalRecordAdded(petId, id, diseaseName, block.timestamp);
        return id;
    }

    function getMedicalRecordsCount(uint256 petId) external view returns (uint256) {
        return _medicalRecords[petId].length;
    }

    function getMedicalRecord(uint256 petId, uint256 index) external view returns (uint256, string memory, string memory, string memory, uint256, uint256) {
        require(index < _medicalRecords[petId].length, "Invalid index");

        MedicalRecord memory record = _medicalRecords[petId][index];
        return (record.petId, record.medicalId, record.record, record.diseaseName, record.medicalExpenses, record.timestamp);
    }
}
