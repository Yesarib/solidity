// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract SmartContractWallet {
    address payable public owner;
    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    mapping(address => bool) public guardians;
    address payable nextOwner;
    mapping(address => mapping(address => bool)) nextOwnerGuardianVotedBool;
    uint guardianResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor() {
        owner = payable(msg.sender);
    }

    function setGuardian(address guardian, bool isGuardian) public {
        require(msg.sender == owner, "You are not the owner");
        guardians[guardian] = isGuardian;
    }

    function proposeNewOner(address payable newOwner) public {
        require(guardians[msg.sender], "You are not guardian of this waller");
        require(nextOwnerGuardianVotedBool[newOwner][msg.sender] == false,"You are already voted." );
        if (newOwner != nextOwner) {
            nextOwner = newOwner;
            guardianResetCount = 0;
        }

        guardianResetCount++;

        if (guardianResetCount >= confirmationsFromGuardiansForReset) {
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setAllowance(address _for, uint amount) public {
        require(msg.sender == owner, "You are not the owner");
        allowance[_for] = amount;

        if (amount > 0) {
            isAllowedToSend[_for] = true;
        } else {
            isAllowedToSend[_for] = false;
        }
    }

    function transfer(address payable to, uint amount, bytes memory payload) public returns(bytes memory) {
        if (msg.sender != owner) {
            require(isAllowedToSend[msg.sender], "You are not allowed to send anything from this mart contract");
            require(allowance[msg.sender] >= amount, "You are trying to send more than you are allowed to");

            allowance[msg.sender] -= amount;
        }

        (bool success, bytes memory retunData) = to.call{value: amount}(payload);
        require(success, "Aborting, call was not successful");

        return retunData;
    }

    receive() external payable { }
}