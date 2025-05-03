// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DcoinStaking is Ownable {
    using SafeMath for uint256;

    IERC20 public dcoin;
    uint256 public constant REWARD_RATE_PER_BLOCK = 10 ** 15; // Example reward rate (adjust as needed)

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimedRewardBlock;
    }

    mapping(address => Stake) public stakes;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(address _dcoin) {
        dcoin = IERC20(_dcoin);
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake zero amount");
        require(dcoin.balanceOf(msg.sender) >= _amount, "Insufficient Dcoin balance");
        dcoin.transferFrom(msg.sender, address(this), _amount);

        Stake storage stake = stakes[msg.sender];
        if (stake.amount == 0) {
            stake.startTime = block.number;
            stake.lastClaimedRewardBlock = block.number;
        }
        stake.amount = stake.amount.add(_amount);
        totalStaked = totalStaked.add(_amount);

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) public {
        Stake storage stake = stakes[msg.sender];
        require(stake.amount >= _amount && _amount > 0, "Insufficient staked amount");

        uint256 reward = calculateReward(msg.sender);
        stake.lastClaimedRewardBlock = block.number; // Claim rewards upon unstaking
        stake.amount = stake.amount.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        dcoin.transfer(msg.sender, _amount.add(reward)); // Return staked amount + reward

        emit Unstaked(msg.sender, _amount);
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address _user) public view returns (uint256) {
        Stake storage stake = stakes[_user];
        uint256 blocksElapsed = block.number - stake.lastClaimedRewardBlock;
        return blocksElapsed.mul(stake.amount).mul(REWARD_RATE_PER_BLOCK).div(10 ** 18); // Assuming reward rate is per Dcoin staked per block
    }

    function claimReward() public {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward to claim");
        stakes[msg.sender].lastClaimedRewardBlock = block.number;
        dcoin.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }
}
