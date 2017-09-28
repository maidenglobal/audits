pragma solidity ^0.4.11;

import './ownable.sol';
import './SafeMath.sol';

contract token_database is ownable {
    using SafeMath for uint;
    
    address public token_contract;
    
    mapping(address => uint) public balances;
    
    uint256 public total_supply;
    
    string public name = "Test GiveCoin";
    string public symbol = "Test GC";
    uint8 public decimals = 2;
    
    function name() constant returns (string) { return name; }
    function symbol() constant returns (string) { return symbol; }
    function decimals() constant returns (uint8) {return decimals;}
        
     /**
     * @dev Constructor.
     */
    function token_database()
    {
        balances[msg.sender] = 5000000000;
        total_supply = balances[msg.sender];
    }
    
    /**
    * @dev Getter function to retrieve a total supply of Give Tokens.
    * @return _supply  Total amount of Give Tokens.
    */
    function totalSupply() constant returns (uint256 _supply)
    {
        return total_supply;
    }
    
    /**
    * @dev Getter function to retrieve a balance of the given address.
    * @param _owner     The address whose balance we want to know.
    * @return _balance  Balance of the given address.
    */
    function balanceOf(address _owner) constant returns (uint _balance)
    {
        return balances[_owner];
    }
    
    /**
    * @dev Increase a balance of the given address by the given amount.
    * @param _owner    The address whose balance should be increased.
    * @param _amount   The amount of tokens that should be added to the _owner's balance.
    */
    function increase_balance(address _owner, uint256 _amount) only_token_contract
    {
        balances[_owner] = balances[_owner].add(_amount);
    }
    
    /**
    * @dev Decrease a balance of the given address by the given amount.
    * @param _owner    The address whose balance should be decreased.
    * @param _amount   The amount of tokens that should be subtracted from the _owner's balance.
    */
    function decrease_balance(address _owner, uint256 _amount) only_token_contract
    {
        balances[_owner] = balances[_owner].sub(_amount);
    }
    
     /** DEBUGGING FUNCTIONS **/
    
    /**
    * @dev Debugging function that allows owner to connect the state storeage contract
    *      with token logic contract.
    * @param _token_contract  The address of token logic contract.
    */
    function configure(address _token_contract) only_owner
    {
        token_contract = _token_contract;
    }
    
    modifier only_token_contract
    {
        if(msg.sender != token_contract)
        {
            throw;
        }
        _;
    }
}
