// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { SetUpTest } from "./helper/SetUp.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract InsuranceTest is SetUpTest {
    
    // users
    address[] users = new address[](10);

    function setUp() public override {
        super.setUp();
        console.log("========== Insurance start ==========");
    }

    // Test1: 10隻寵物註冊 NFT
    function test_ten_pets_mint() public{
        console.log("========== Mint Pet NFT Start ==========");
    
        for(uint i = 1; i <= 10; i++){
            string memory userName = string(abi.encodePacked("user", Strings.toString(i)));
            users[i-1] = makeAddr(userName);
            string memory petName = string(abi.encodePacked("pet name", Strings.toString(i)));
            petNft.mintPet(users[i-1], i, petName, "cat", 1);
            console.log("%s mint %s, id is %s",userName, petName, i);

            (uint256 id,,,,) = petNft.getPetInfo(i);
            assertEq(id, i);
            
        }
        console.log("========== Mint Pet End ==========");
    }
    
    // Test2: 10隻寵物投保
    function test_ten_pets_insure() public{

        test_ten_pets_mint();

        uint256 coverageAmount = 500;
        string memory _poolName = insurance.createInsurancePool("cat", "surgery", coverageAmount);
        console.log("---------------------------------------------");
        console.log("Create a pool [%s], coverage amount %s wei ether", _poolName, coverageAmount);
        console.log("---------------------------------------------");
        
        console.log("========== Pet Insure Start ==========");

        for(uint i = 1; i <= 10; i++){
            vm.startPrank(users[i-1]);
            deal(users[i-1], 1 ether);

            insurance.purchaseInsurance{value: coverageAmount}(i, _poolName);
            console.log("users%s purchase insurance for pet id %s in pool [%s]", i, i, _poolName);
            
            // 確認有得到 token
            assertEq(token.balanceOf(users[i-1]), 1 * 10 ** token.getDecimals());
            // 確認有投保成功
            require(insurance.insurancePetsinPools(_poolName,i));
            // 確認資金池有匯入保費
            assertEq(reserveFund.getReserveBalance(_poolName), i * coverageAmount);

            vm.stopPrank();
        }

        console.log("========== Pet Insure End ==========");
    }

    // Test3: 1隻寵物理賠
    function test_one_pet_claim() public {

        test_ten_pets_insure();

        console.log("========== Pet Claim Start ==========");

        // pet1 新增就醫紀錄
        vm.startPrank(doctor);
        string memory id = petMedicalRecord.addMedicalRecord(1, "surgery", "Feline Infectious Peritonitis", 2000);
        console.log("---------------------------------------------");
        console.log("Doctor add a medical record for pet id %s", 1);
        console.log("Treatment record is [%s] and diseaseName is [%s]", "surgery", "Feline Infectious Peritonitis");
        console.log("This treatment cost %s wei ether", 2000);
        console.log("---------------------------------------------");
        vm.stopPrank();

        // user1 申請理賠
        vm.startPrank(users[0]);

        uint preBalance = users[0].balance;
        insuranceClaim.fileClaim(1, "cat/surgery", id);
        uint claimAmount = users[0].balance - preBalance;

        assertEq(claimAmount, 2000 * 80 / 100);
        console.log("User call fileClaim() and success claim for %s wei ether", claimAmount);

        vm.stopPrank();
        console.log("========== Pet Claim End ==========");

    }

    // Test4: 確認資金池餘額是否正確減少
    function test_reserveFund_correct() public {

        test_ten_pets_insure();

        console.log("========== Reserve Fund Check Start ==========");

        uint fundPreBalance = reserveFund.getReserveBalance("cat/surgery");

        console.log("Fund at the beginning : %s wei ether", fundPreBalance);

        // pet1 新增就醫紀錄
        vm.startPrank(doctor);
        string memory id = petMedicalRecord.addMedicalRecord(1, "surgery", "Feline Infectious Peritonitis", 2000);
        vm.stopPrank();

        // user1 申請理賠
        vm.startPrank(users[0]);
        uint preBalance = users[0].balance;
        insuranceClaim.fileClaim(1, "cat/surgery", id);
        uint claimAmount = users[0].balance - preBalance;
        console.log("User call fileClaim() and success claim for %s wei ether", claimAmount);
        vm.stopPrank();

        uint fundPostBalance = reserveFund.getReserveBalance("cat/surgery");
        assertEq(fundPreBalance - fundPostBalance, claimAmount);

        console.log("Fund after the claim : %s wei ether", fundPostBalance);

        console.log("========== Reserve Fund Check End ==========");
    }

    // Test5: 醫療紀錄和實際投保項目不同，理賠失敗
    function test_claim_failed() public {
        test_ten_pets_insure();

        console.log("========== Pet Claim Start ==========");

        // pet1 新增就醫紀錄
        vm.startPrank(doctor);
        string memory id = petMedicalRecord.addMedicalRecord(1, "X-ray", "Feline Infectious Peritonitis", 400);
        console.log("---------------------------------------------");
        console.log("Doctor add a medical record for pet id %s", 1);
        console.log("Treatment record is [%s] and diseaseName is [%s]", "X-ray", "Feline Infectious Peritonitis");
        console.log("This treatment cost %s wei ether", 400);
        console.log("---------------------------------------------");
        vm.stopPrank();

        // user1 申請理賠(失敗)
        vm.startPrank(users[0]);

        vm.expectRevert();
        insuranceClaim.fileClaim(1, "cat/surgery", id);
        console.log("User call fileClaim() faild because the pool is for surgery");

        vm.stopPrank();
        console.log("========== Pet Claim End ==========");
    }
}