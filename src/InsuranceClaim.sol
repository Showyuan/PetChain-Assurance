// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IReserveFund} from "./interface/IReserveFund.sol";
import {IPetNFT} from "./interface/IPetNFT.sol";
import {IToken} from "./interface/IToken.sol";
import {IInsurance} from "./interface/IInsurance.sol";
import {IPetMedicalRecord} from "./interface/IPetMedicalRecord.sol";
import "forge-std/console.sol";

contract InsuranceClaim {

    address private PET_NFT_ADDR;
    address private PET_TOKEN_ADDR;
    address private RESERVE_FUND_ADDR;
    address private INSURANCE_ADDR;
    address private MRECORD_ADDR;
    address private GOVERNANCE_ADDR;

    event Fraud(uint256 indexed petId, string poolName);

    constructor(address petNft, address petToken, address reserveFund, address insurance, address medicalRecord, address governance) {
        PET_NFT_ADDR = petNft;
        PET_TOKEN_ADDR = petToken;
        RESERVE_FUND_ADDR = reserveFund;
        INSURANCE_ADDR = insurance;
        MRECORD_ADDR = medicalRecord;
        GOVERNANCE_ADDR = governance;
    }

    /**
        fileClaim 申請理賠
        petId: 寵物晶片ID
        poolName: 保險名稱
     */
    function fileClaim(uint256 petId, string memory poolName, string memory id) external {
        
        (uint index, bool allow) = checkFraud(petId, poolName, id);
        (,,,, address owner) = IPetNFT(PET_NFT_ADDR).getPetInfo(petId);

        if(msg.sender != GOVERNANCE_ADDR){
            require(allow, "Recommend going into the governance process");
            require(owner == msg.sender, "Only policyholders can file a claim");
        }

        (,,,, uint medicalExpenses,) = IPetMedicalRecord(MRECORD_ADDR).getMedicalRecord(petId, index);
        uint claimAmount = medicalExpenses * 80 / 100;
        require(IReserveFund(RESERVE_FUND_ADDR).getReserveBalance(poolName) > claimAmount, "Insufficient funds in the reserve");

        IReserveFund(RESERVE_FUND_ADDR).disburseClaim(poolName, claimAmount, owner);
    }

    /**
        checkFraud 確認是否有欺騙行為
        petId: 寵物晶片ID
        poolName: 保險名稱
     */
    function checkFraud(uint256 petId, string memory poolName, string memory id) internal returns (uint, bool){
        // 確認有投保
        (, string memory medicalProcedure,) = IInsurance(INSURANCE_ADDR).getInsurancePool(poolName);

        // 確認保險還沒到期
        uint expireTime = IInsurance(INSURANCE_ADDR).getExpireTime(petId, poolName);
        uint startTime = expireTime - 365 days;
        require(expireTime >= block.timestamp, "Insurance Expired");

        // 確認醫療紀錄正確
        uint count = IPetMedicalRecord(MRECORD_ADDR).getMedicalRecordsCount(petId);
        for(uint i = 0; i < count; i++){
            (, string memory medicalId, string memory record,,, uint timestamp) = IPetMedicalRecord(MRECORD_ADDR).getMedicalRecord(petId, i);
            
            if(keccak256(abi.encodePacked(id)) == keccak256(abi.encodePacked(medicalId)) && startTime <= timestamp){
                if(keccak256(abi.encodePacked(medicalProcedure)) == keccak256(abi.encodePacked(record))){
                    return (i, true);
                } else {
                    return (i, false);
                }
            }
        }
        emit Fraud(petId, poolName);
        return (type(uint).max, false);
    }
}