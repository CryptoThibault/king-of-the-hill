// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract KingOfTheHill {
    mapping(address => uint256) private _userBalances;
    uint256 private _blocks;
    uint256 private _base;
    uint256 private _pot;
    address private _owner;
    address private _winner;

    event Deposit(address indexed account, uint256 amount);
    event Withdrew(address indexed account, uint256 amount);
    event TimeReach(address indexed winner, uint256 amount);

    constructor(uint256 blocks_) payable {
        require(msg.value >= 1e9, "KingOfTheHill: send more than 1gwei");
        _blocks = block.number + blocks_;
        _base = blocks_;
        _owner = msg.sender;
        _winner = msg.sender;
        _pot = msg.value;
    }

    function deposit() public payable {
        _timeReached();
        require(
            msg.value >= _pot * 2,
            "KingOfTheHill: send the double of the actual pot"
        );
        require(msg.sender != _owner, "KingOfTheHill: owner can not play");
        require(
            msg.sender != _winner,
            "KingOfTheHill winner have to wait another deposit"
        );
        emit Deposit(msg.sender, msg.value);
        _winner = msg.sender;
        uint256 rest = msg.value - _pot * 2;
        if (rest > 0) payable(msg.sender).transfer(rest);
        _pot += msg.value - rest;
    }

    function deposit(uint256 amount) public payable {
        _timeReached();
        require(
            _userBalances[msg.sender] >= amount,
            "can not send more than actual balance"
        );
        require(
            amount >= _pot * 2,
            "KingOfTheHill: send the double of the actual pot"
        );
        require(msg.sender != _owner, "KingOfTheHill: owner can not play");
        require(
            msg.sender != _winner,
            "KingOfTheHill: winner have to wait another deposit"
        );
        emit Deposit(msg.sender, amount);
        _winner = msg.sender;
        uint256 rest = amount - _pot * 2;
        if (rest > 0) payable(msg.sender).transfer(rest);
        _pot += amount - rest;
    }

    function withdraw() public {
        uint256 amount = _userBalances[msg.sender];
        require(
            _userBalances[msg.sender] > 0,
            "KingOfTheHill: can not withdraw 0 ether"
        );
        emit Withdrew(msg.sender, amount);
        _userBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawOwner() public {
        require(
            msg.sender == _owner,
            "KingOfTheHill: access reserved to owner"
        );
        uint256 amount = _userBalances[msg.sender];
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
            _blocks = block.number + _base;
        }
    }

    function withdrawall() public {
        require(
            msg.sender == _owner,
            "KingOfTheHill: access reserved to owner"
        );
        payable(msg.sender).transfer(address(this).balance);
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

    function blocks() public view returns (uint256) {
        return _blocks;
    }

    function blocknumber() public view returns (uint256) {
        return block.number;
    }
}
