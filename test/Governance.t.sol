// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { SetUpTest } from "./helper/SetUp.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract GovernanceTest is SetUpTest {
    
    // user
    address user = makeAddr("user");

    function setUp() public override {
        super.setUp();
        console.log("========== Governance start ==========");
    }

    function test_claim_failed_proposal() public{
        // governance.createProposal(target, abi.encodeWithSignature("", arg), description);
    }
}