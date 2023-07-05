// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IToken} from "./interface/IToken.sol";
import {IInsurance} from "./interface/IInsurance.sol";

contract Governance {
    IToken public tokenAddress;
    IInsurance public insuranceAddress;

    address[] public tokenHolders;
    mapping(address => uint256) public votingPower;
    uint256 public constant VOTING_DURATION = 3 days;

    struct Proposal {
        uint256 id;                         // 提案編號
        address target;                     // 執行合約地址
        string description;                 // 描述
        bytes data;                         // calldata
        uint256 votesFor;                   // 支持票
        uint256 votesAgainst;               // 反對票
        uint256 startTime;                  // 提案開始時間
        bool executed;                      // 是否已經執行過
        bool passed;                        // 是否通過
    }

    Proposal[] public proposals;
    uint256 public nextProposalId;
    mapping(uint => mapping(address => bool)) voted;

    event ProposalCreated(uint256 indexed id, string description);
    event VoteCasted(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId, bool passed);

    constructor(address _tokenAddress, address _insuranceAddress) {
        tokenAddress = IToken(_tokenAddress);
        insuranceAddress = IInsurance(_insuranceAddress);
        nextProposalId = 1;
    }

    modifier onlyTokenHolders() {
        require(tokenAddress.balanceOf(msg.sender) > 0, "Only token holders can perform this action");
        _;
    }

    /**
        createProposal 新增提案
        target: 執行合約地址
        data: calldata
        description: 描述
     */
    function createProposal(address target, bytes memory data, string memory description) external onlyTokenHolders {
        Proposal memory proposal;
        proposal.target = target;
        proposal.data = data;
        proposal.id = nextProposalId;
        proposal.description = description;
        proposal.startTime = block.timestamp;

        proposals.push(proposal);

        emit ProposalCreated(proposal.id, proposal.description);

        nextProposalId++;
    }

    /**
        vote 投票
        proposalId: 提案編號
        support: 是否支持
     */
    function vote(uint256 proposalId, bool support) external onlyTokenHolders {
        Proposal storage proposal = proposals[proposalId - 1];
        require(proposal.startTime + VOTING_DURATION > block.timestamp, "Voting period has ended");
        require(!voted[proposalId][msg.sender], "Already voted for this proposal");

        if (support) {
            proposal.votesFor += 1;
        } else {
            proposal.votesAgainst += 1;
        }

        voted[proposalId][msg.sender] = true;

        emit VoteCasted(proposalId, msg.sender, support);
    }

    /**
        executeProposal 執行提案
        proposalId: 提案編號
     */
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId - 1];
        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.startTime + VOTING_DURATION <= block.timestamp, "Voting period has not ended yet");

        // todo 要改成過半數嗎？
        require(proposal.votesFor > proposal.votesAgainst, "Proposal don't approve!");

        proposal.passed = true;
        proposal.executed = true;
        address target = proposal.target;
        (bool result,) = target.call(proposal.data);
        require(result, "Proposal execute failed!");

        emit ProposalExecuted(proposalId, proposal.passed);
    }
}
