// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DGovToken is ERC20, Ownable {
    constructor() ERC20("Dcoin Governance Token", "DGOV") {
        // Initial supply can be minted to the deployer or distributed based on Dcoin holdings
        _mint(msg.sender, 1000000 * (10 ** decimals())); // Example initial supply
    }
}
