// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    uint256 totalWaves;
    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;
    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    
    }

    Wave[] waves;

    constructor() payable {
        console.log("Yo yo, What it do");
    }

    mapping(address => uint256) public lastWavedAt;

    function wave( string memory _message) public {

        //We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 15m"
        );
        // Update the current timestamp we have for the user
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));


        /*
         * Generate a Psuedo random number between 0 and 100
         */
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNumber);
        seed = randomNumber;
        if (randomNumber > 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }
}