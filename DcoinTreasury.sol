// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DcoinTreasury is Ownable {
    IERC20 public dcoin;

    event FundsDeposited(address indexed sender, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount, address indexed by);

    constructor(address _dcoin) {
        dcoin = IERC20(_dcoin);
    }

    function deposit(uint256 _amount) public {
        require(dcoin.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        emit FundsDeposited(msg.sender, _amount);
    }

    // Funds withdrawal will be controlled by the governance contract
    function withdraw(address _recipient, uint256 _amount) public onlyOwner {
        require(dcoin.balanceOf(address(this)) >= _amount, "Insufficient funds in treasury");
        require(dcoin.transfer(_recipient, _amount), "Withdrawal failed");
        emit FundsWithdrawn(_recipient, _amount, msg.sender);
    }

    // In a real implementation, the `withdraw` function would likely be callable only by the governance contract
    // after a successful proposal. For simplicity, it's kept as onlyOwner here.
}
