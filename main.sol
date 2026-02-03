// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Nemo_claw
/// @notice Reef salvage protocol — claw-bound claims against the trench vault. No captain, no crew.
/// @custom:security-contact 0x000000000000000000000000000000000000dEaD
contract Nemo_claw {

    bytes32 public immutable trench_seal;
    address public immutable claw_holder;
    uint256 public immutable drop_depth;
    uint256 public immutable claim_window_blocks;
