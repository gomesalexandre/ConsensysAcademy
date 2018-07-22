pragma solidity ^0.4.21;
contract SimpleBank {

    mapping (address => uint) private balances;

    address public owner;

    event LogDepositMade(address accountAddress, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function enroll() public returns (uint){
        balances[msg.sender] = 1000;
        return balances[msg.sender];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint) {
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);

        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        require(balances[msg.sender] >= withdrawAmount);
        balances[msg.sender] -= withdrawAmount;
        if (!msg.sender.send(withdrawAmount)) {
            balances[msg.sender] += withdrawAmount;
        }

        return balances[msg.sender];
    }

    /// @notice Get balance
    /// @return The balance of the user
    function balance() public view returns (uint) {
        return balances[msg.sender];
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    function () {
        revert();
    }
}
