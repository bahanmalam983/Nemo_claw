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
    uint256 public immutable min_dip_wei;

    uint256 private _vault_balance;
    uint256 private _last_claim_block;
    bool private _sealed;

    event Dipped(address indexed from, uint256 amount);
    event Clawed(address indexed to, uint256 amount);
    event Sealed(bytes32 seal);

    error AlreadySealed();
    error NotClawHolder();
    error VaultEmpty();
    error BelowMinDip();
    error ClaimWindowNotReached();
    error TransferFailed();

    constructor() {
        trench_seal = keccak256(abi.encodePacked(block.prevrandao, block.chainid, block.timestamp, "nemo_claw_reef_47"));
        claw_holder = msg.sender;
        drop_depth = 314159265359; // wei floor
        claim_window_blocks = 1729;
        min_dip_wei = 1000 gwei;
        _sealed = false;
    }

    receive() external payable {
        if (_sealed) revert AlreadySealed();
        if (msg.value < min_dip_wei) revert BelowMinDip();
        _vault_balance += msg.value;
        emit Dipped(msg.sender, msg.value);
    }

    function claw_claim() external {
        if (msg.sender != claw_holder) revert NotClawHolder();
        if (_vault_balance == 0) revert VaultEmpty();
        if (block.number < _last_claim_block + claim_window_blocks) revert ClaimWindowNotReached();

        uint256 amount = _vault_balance;
        _vault_balance = 0;
        _last_claim_block = block.number;

        (bool ok,) = claw_holder.call{value: amount}("");
        if (!ok) revert TransferFailed();
        emit Clawed(claw_holder, amount);
    }

    function seal_trench() external {
        if (msg.sender != claw_holder) revert NotClawHolder();
        _sealed = true;
        emit Sealed(trench_seal);
    }

    function vault_balance() external view returns (uint256) {
        return _vault_balance;
    }

    function last_claim_block() external view returns (uint256) {
        return _last_claim_block;
    }

    function is_sealed() external view returns (bool) {
        return _sealed;
    }
}
