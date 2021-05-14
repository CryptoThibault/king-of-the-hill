// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract KingOfTheHill {
    mapping(address => uint256) private _userBalances;
    uint256 private _blocks;
    uint256 private _baseBlocks;
    uint256 private _pot;
    address private _owner;
    address private _winner;

    event Deposit(address indexed account, uint256 amount);
    event Withdrew(address indexed account, uint256 amount);
    event TimeReach(address indexed winner, uint256 amount);

    constructor(uint256 blocks_) payable {
        require(msg.value >= 1e9, "KingOfTheHill: send more than 1gwei");
        _baseBlocks = blocks_;
        _blocks = block.number + _baseBlocks;
        _owner = msg.sender;
        _winner = msg.sender;
        _pot = msg.value;
    }

    function deposit() public payable {
        _timeReached;
        require(
            msg.value >= _pot * 2,
            "KingOfTheHill: send the double of the actual balance"
        );
        require(msg.sender != _owner, "KingOfTheHill: owner can not play");
        emit Deposit(msg.sender, msg.value);
        _winner = msg.sender;
        uint256 amount = msg.value - _pot * 2;
        if (amount > 0) payable(msg.sender).transfer(amount);
        _pot += msg.value - amount;
    }

    function withdraw() public {
        uint256 amount = _userBalances[msg.sender];
        require(
            _userBalances[msg.sender] > 0,
            "SmartWallet: can not withdraw 0 ether"
        );
        emit Withdrew(msg.sender, amount);
        _userBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function _timeReached() private {
        if (block.number > _blocks) {
            emit TimeReach(_winner, (_pot * 8) / 10);
            _userBalances[_winner] = (_pot * 8) / 10;
            _userBalances[_owner] = _pot / 10;
            _pot = _pot / 10;
            _blocks = block.number + _baseBlocks;
        }
    }

    function pot() public view returns (uint256) {
        return _pot;
    }

    function balance() public view returns (uint256) {
        return _userBalances[msg.sender];
    }

    function winner() public view returns (address) {
        return _winner;
    }

    function timeleft() public view returns (uint256) {
        return _blocks - block.number;
    }
}
