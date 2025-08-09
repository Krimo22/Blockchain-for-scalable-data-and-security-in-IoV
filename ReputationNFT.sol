// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ReputationNFT is ERC721 {
    // Track reputation scores (0-100)
    mapping(address => uint256) public repScores;
    // Track token IDs (1 vehicle = 1 NFT)
    mapping(address => uint256) public tokenIds;
    uint256 public nextTokenId = 1;

    // Only zkSync L2 can call this (cross-chain security)
    address public l2ConsensusContract;

    constructor(address _l2ConsensusContract) ERC721("IoVReputation", "REP") {
        l2ConsensusContract = _l2ConsensusContract;
    }

    // Mint a reputation NFT for a new vehicle
    function mint(address vehicle) external {
        require(tokenIds[vehicle] == 0, "Vehicle already registered");
        _safeMint(vehicle, nextTokenId);
        tokenIds[vehicle] = nextTokenId;
        repScores[vehicle] = 50; // Initial score = 50
        nextTokenId++;
    }

    // Update reputation score (called by zkSync L2)
    function updateRep(address vehicle, int256 delta) external {
        require(msg.sender == l2ConsensusContract, "Unauthorized");
        if (delta > 0) {
            repScores[vehicle] += uint256(delta);
            if (repScores[vehicle] > 100) repScores[vehicle] = 100;
        } else {
            repScores[vehicle] -= uint256(-delta);
            if (repScores[vehicle] < 0) repScores[vehicle] = 0;
        }
    }
}