// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { InsuranceTest } from "./InsuranceTest.t.sol";

contract GovernanceTest is InsuranceTest {

    // Test1: 測試提案，並且通過後成功執行
    function test_create_proposal_success() public{
        
        test_claim_failed();

        console.log("========== Governance Start ==========");

        vm.prank(users[0]);
        governance.createProposal(address(insuranceClaim), abi.encodeWithSignature("fileClaim(uint256,string,string)", 1, "cat/surgery", "1-0"), "Voting on disputed claims");
        console.log("User1 create a proposal about calling fileClaim(), proposal id: %s", governance.nextProposalId() - 1);

        for(uint i = 1; i <= 10; i++){
            vm.prank(users[i - 1]);
            governance.vote(1, true);
            console.log("User%s vote the proposal :%s", i, true);
        }

        vm.warp(block.timestamp + 4 days);
        console.log("Execute Proposal Succeed");
        governance.executeProposal(1);

        console.log("========== Governance End ==========");
    }

    // Test2: 測試提案，並且投票失敗
    function test_create_proposal_failed() public{
        
        test_claim_failed();

        console.log("========== Governance Start ==========");

        vm.startPrank(users[0]);
        governance.createProposal(address(insuranceClaim), abi.encodeWithSignature("fileClaim(uint256,string,string)", 1, "cat/surgery", "1-0"), "Voting on disputed claims");
        console.log("User1 create a proposal about calling fileClaim(), proposal id: %s", governance.nextProposalId() - 1);
        governance.vote(1, true);
        vm.stopPrank();

        for(uint i = 2; i <= 10; i++){
            vm.prank(users[i - 1]);
            governance.vote(1, false);
            console.log("User%s vote the proposal :%s", i, false);
        }

        vm.warp(block.timestamp + 4 days);
        console.log("Execute Proposal Failed");
        vm.expectRevert();
        governance.executeProposal(1);

        console.log("========== Governance End ==========");
    }
}