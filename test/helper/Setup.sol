// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../src/Token.sol";
import "../../src/PetNFT.sol";
import "../../src/PetMedicalRecord.sol";
import "../../src/ReserveFund.sol";
import "../../src/Insurance.sol";
import "../../src/InsuranceClaim.sol";
import "../../src/Governance.sol";

contract SetUpTest is Test {
    
    Token token;
    PetNFT petNft;
    PetMedicalRecord petMedicalRecord;
    ReserveFund reserveFund;
    Insurance insurance;
    InsuranceClaim insuranceClaim;
    Governance governance;

    address owner = makeAddr("owner");

    function setUp() public virtual{

        vm.startPrank(owner);

        token = new Token("Insurance", "INS");
        petNft = new PetNFT("PET", "PET");
        petMedicalRecord = new PetMedicalRecord();
        reserveFund = new ReserveFund();
        insurance = new Insurance(address(petNft), address(token), address(reserveFund));
        governance = new Governance(address(token), address(insurance));
        insuranceClaim = new InsuranceClaim(address(petNft), address(token), address(reserveFund), address(insurance), address(petMedicalRecord), address(governance));
        reserveFund.setClaimAddr(address(insuranceClaim));

        vm.stopPrank();
    }
}