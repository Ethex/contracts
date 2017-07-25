pragma solidity ^0.4.13;


// ----------------------------------------------------------------------------------------------
// Derived from: Sample fixed supply token contract
// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
// (c) Ethex LLC 2017.
// ----------------------------------------------------------------------------------------------

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Etx is ERC20Interface {
    string public constant symbol = "ETX";

    string public constant name = "Ethex supporter token.";

    uint8 public constant decimals = 18;

    uint256 public blocksToVest;

    uint256 constant _totalSupply = 10000 * (1 ether);

    // Owner of this contract
    address public owner;

    // Balances for each account
    mapping (address => uint256) balances;

    // Vesting start for each account.
    mapping (address => uint256) vestingStartBlock;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    function Etx(uint256 _blocksToVest) {
        blocksToVest = _blocksToVest;
        owner = msg.sender;
        balances[owner] = _totalSupply;
        vestingStartBlock[owner] = block.number;
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    //in case the client wants to display how long until they are vested.
    function vestingStartBlockOf(address _owner) constant returns (uint256 blockNumber) {
        if (balances[_owner] >= (1 ether)) {
          return vestingStartBlock[_owner];
        }
        return block.number;
    }

    function isVested(address _owner) constant returns (bool vested) {
        if (balances[_owner] >= (1 ether) &&
        vestingStartBlock[_owner] + blocksToVest <= block.number) {
            return true;
        }
        return false;
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            // Record current _to balance.
            uint256 previousBalance = balances[_to];

            // Transfer.
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;

            // If "_to" crossed the 1 ETX level in this transaction, this is the vesting start block.
            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                vestingStartBlock[_to] = block.number;
            }

            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount &&
        allowed[_from][msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            // Record current _to balance.
            uint256 previousBalance = balances[_to];

            // Transfer.
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;

            // If "_to" crossed the 1 ETX level in this transaction, this is the vesting start block.
            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                vestingStartBlock[_to] = block.number;
            }

            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
