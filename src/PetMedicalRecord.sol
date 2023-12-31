// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract PetMedicalRecord {
    
    address private owner;

    // 醫生的白名單
    mapping(address => bool) public whitelist;

    struct MedicalRecord {
        uint256 petId;             // 晶片ID
        string medicalId;          // 就醫紀錄ID
        string record;             // 治療內容
        string diseaseName;        // 病名
        uint256 medicalExpenses;   // 診療費
        uint256 timestamp;         // 時間戳
        bool isClaim;              // 是否已經理賠
    }

    // 寵物晶片ID => 醫療紀錄
    mapping(uint256 => MedicalRecord[]) public _medicalRecords;

    event MedicalRecordAdded(uint256 indexed petId, string indexed medicalId, string diseaseName, uint256 timestamp);

    modifier onlyDoctor() {
        require(whitelist[msg.sender], "Only owner can call the function");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call the function");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    /**
        registerDoctor 新醫生註冊
        newDoctorAddr: 醫生地址
     */
    function registerDoctor(address newDoctorAddr) external onlyOwner{
        require(newDoctorAddr != address(0), "Address can't be 0");

        whitelist[newDoctorAddr] = true;
    }
    
    /**
        addMedicalRecord 新增醫療紀錄
        petId: 晶片ID
        record: 治療內容
        diseaseName: 病名
        medicalExpenses: 診療費
     */
    function addMedicalRecord(uint256 petId, string memory record, string memory diseaseName, uint256 medicalExpenses) external onlyDoctor returns (string memory id){
        id = string(abi.encodePacked(Strings.toString(petId), "-",  Strings.toString(_medicalRecords[petId].length)));

        MedicalRecord memory newRecord = MedicalRecord({
            petId: petId,
            medicalId: id,
            record: record,
            diseaseName: diseaseName,
            medicalExpenses: medicalExpenses,
            timestamp: block.timestamp,
            isClaim: false
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
    function getMedicalRecord(uint256 petId, uint256 index) external view returns (uint256, string memory, string memory, string memory, uint256, uint256, bool) {
        require(index < _medicalRecords[petId].length, "Invalid index");

        MedicalRecord memory record = _medicalRecords[petId][index];
        return (record.petId, record.medicalId, record.record, record.diseaseName, record.medicalExpenses, record.timestamp, record.isClaim);
    }
}
