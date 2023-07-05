// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract PetMedicalRecord {
    
    //todo: 就醫紀錄應該要驗證白名單地址

    struct MedicalRecord {
        uint256 petId;             // 晶片ID
        string medicalId;          // 就醫紀錄ID
        string record;             // 治療內容
        string diseaseName;        // 病名
        uint256 medicalExpenses;   // 診療費
        uint256 timestamp;         // 時間戳
    }

    // 寵物晶片ID => 醫療紀錄
    mapping(uint256 => MedicalRecord[]) public _medicalRecords;

    event MedicalRecordAdded(uint256 indexed petId, string indexed medicalId, string diseaseName, uint256 timestamp);

    /**
        addMedicalRecord 新增醫療紀錄
        petId: 晶片ID
        record: 治療內容
        diseaseName: 病名
        medicalExpenses: 診療費
     */
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

    /**
        getMedicalRecordsCount 取得醫療紀錄筆數
        petId: 晶片ID
     */
    function getMedicalRecordsCount(uint256 petId) external view returns (uint256) {
        return _medicalRecords[petId].length;
    }

    /**
        getMedicalRecord 取得醫療紀錄
        petId: 晶片ID
        index: 第幾筆紀錄
     */
    function getMedicalRecord(uint256 petId, uint256 index) external view returns (uint256, string memory, string memory, string memory, uint256, uint256) {
        require(index < _medicalRecords[petId].length, "Invalid index");

        MedicalRecord memory record = _medicalRecords[petId][index];
        return (record.petId, record.medicalId, record.record, record.diseaseName, record.medicalExpenses, record.timestamp);
    }
}
