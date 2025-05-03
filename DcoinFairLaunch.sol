// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DcoinFairLaunch is Ownable {
    IERC20 public dcoin;
    uint256 public constant AIRDROP_AMOUNT = 2100000 * (10 ** 18); // 10% for airdrop
    uint256 public constant SALE_AMOUNT = 8400000 * (10 ** 18);  // 40% for public sale
    uint256 public constant TREASURY_AMOUNT = 4200000 * (10 ** 18); // 20% for treasury
    uint256 public constant STAKING_REWARDS_AMOUNT = 4200000 * (10 ** 18); // 20% for staking rewards
    uint256 public constant LIQUIDITY_INCENTIVES_AMOUNT = 2100000 * (10 ** 18); // 10% for liquidity incentives

    mapping(address => bool) public airdropClaimed;

    event AirdropClaimed(address indexed user, uint256 amount);
    event SalePurchase(address indexed buyer, uint256 amountDcoin, uint256 amountETH);

    constructor(address _dcoin) {
        dcoin = IERC20(_dcoin);
        // Ensure the Dcoin contract has the total supply
        require(dcoin.totalSupply() == 21000000 * (10 ** 18), "Dcoin total supply mismatch");
        // Transfer the allocated amounts from the deployer to this contract
        dcoin.transferFrom(msg.sender, address(this), AIRDROP_AMOUNT + SALE_AMOUNT + TREASURY_AMOUNT + STAKING_REWARDS_AMOUNT + LIQUIDITY_INCENTIVES_AMOUNT);
    }

    function claimAirdrop() public {
        require(!airdropClaimed[msg.sender], "Airdrop already claimed");
        airdropClaimed[msg.sender] = true;
        // Airdrop amount is symbolic for demonstration, adjust as needed
        dcoin.transfer(msg.sender, 1000 * (10 ** 18));
        emit AirdropClaimed(msg.sender, 1000 * (10 ** 18));
    }

    function purchaseDcoin() public payable {
        require(dcoin.balanceOf(address(this)) >= SALE_AMOUNT, "Not enough Dcoin for sale");
        // Example: 1 ETH buys X Dcoin. Adjust the rate as needed.
        uint256 dcoinAmount = msg.value * 1000; // 1 ETH = 1000 DCOIN (example rate)
        require(dcoin.balanceOf(address(this)) >= dcoinAmount, "Not enough Dcoin available for this purchase");
        dcoin.transfer(msg.sender, dcoinAmount);
        payable(owner()).transfer(msg.value); // Send ETH to the owner (for simplicity)
        emit SalePurchase(msg.sender, dcoinAmount, msg.value);
    }

    // Functions to transfer the allocated amounts to their respective contracts/addresses
    function transferTreasury(address _treasury) public onlyOwner {
        require(dcoin.balanceOf(address(this)) >= TREASURY_AMOUNT, "Not enough Dcoin in FairLaunch for treasury");
        dcoin.transfer(_treasury, TREASURY_AMOUNT);
    }

    function transferStakingRewards(address _staking) public onlyOwner {
        require(dcoin.balanceOf(address(this)) >= STAKING_REWARDS_AMOUNT, "Not enough Dcoin in FairLaunch for staking");
        dcoin.transfer(_staking, STAKING_REWARDS_AMOUNT);
    }

    function transferLiquidityIncentives(address _incentives) public onlyOwner {
        require(dcoin.balanceOf(address(this)) >= LIQUIDITY_INCENTIVES_AMOUNT, "Not enough Dcoin in FairLaunch for incentives");
        dcoin.transfer(_incentives, LIQUIDITY_INCENTIVES_AMOUNT);
    }

    // In a real scenario, the airdrop and sale mechanisms would be more sophisticated.
}
