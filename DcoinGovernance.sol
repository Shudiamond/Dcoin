// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Timers.sol";

contract DcoinGovernance is Ownable, Timers {
    IERC20 public dgov;
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant QUORUM_THRESHOLD = 51; // Percentage of total DGov needed for quorum

    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        address proposer;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    event ProposalCreated(uint256 id, address proposer, string description);
    event VoteCast(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 id);

    constructor(address _dgov) {
        dgov = IERC20(_dgov);
    }

    function createProposal(string memory _description) public {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + VOTING_PERIOD;
        newProposal.proposer = msg.sender;
        emit ProposalCreated(proposalCount, msg.sender, _description);
    }

    function castVote(uint256 _proposalId, bool _support) public {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting period has ended or not started");
        require(!proposal.executed, "Proposal has already been executed");
        require(!proposal.hasVoted[msg.sender], "Voter has already voted");

        uint256 voterPower = dgov.balanceOf(msg.sender);
        require(voterPower > 0, "Voter has no voting power");

        proposal.hasVoted[msg.sender] = true;
        if (_support) {
            proposal.yesVotes += voterPower;
        } else {
            proposal.noVotes += voterPower;
        }
        emit VoteCast(_proposalId, msg.sender, _support);
    }

    function executeProposal(uint256 _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting period has not ended");
        require(!proposal.executed, "Proposal has already been executed");

        uint256 totalDGovSupply = dgov.totalSupply();
        uint256 quorum = (totalDGovSupply * QUORUM_THRESHOLD) / 100;
        require(proposal.yesVotes >= quorum, "Quorum not reached");
        require(proposal.yesVotes > proposal.noVotes, "Proposal failed to pass");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
        // In a real implementation, this function would trigger actions based on the proposal.
        // For example, transferring funds from the treasury, changing contract parameters, etc.
    }
}
