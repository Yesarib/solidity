// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract StructExample {
    struct Transaction {
        uint amount;
        uint timestamp;
    }

    struct Balance {
        uint totalBalance;
        uint numDeposits;
        mapping(uint => Transaction) deposits;
        uint numWithdrawals;
        mapping(uint => Transaction) withdrawals;
    }

    mapping(address => Balance) public balances;

    function getDepositNum(address from, uint numDeposit) public view returns(Transaction memory) {
        return balances[from].deposits[numDeposit];
    }

    function depositMoney() public payable {
        balances[msg.sender].totalBalance += msg.value;

        Transaction memory deposit = Transaction(msg.value, block.timestamp);
        balances[msg.sender].deposits[balances[msg.sender].numDeposits] = deposit;
        balances[msg.sender].numDeposits++;
    }

    function withDrawMoney(address payable to, uint amount) public {
        balances[msg.sender].totalBalance -= amount;

        Transaction memory withdrawal = Transaction(amount, block.timestamp);
        balances[msg.sender].withdrawals[balances[msg.sender].numWithdrawals] = withdrawal;
        balances[msg.sender].numWithdrawals++;

        to.transfer(amount);
    }
}