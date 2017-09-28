pragma solidity ^0.4.11;

import './token_database.sol';
import './ownable.sol';
import './SafeMath.sol';

contract ERC223ReceivingContract
{
    
     /**
     * @dev ERC223 standard `tokenFallback` function to handle incoming token transactions.
     * @param _addr   The address of the contract of the tokens that have been deposited.
     * @param _amount The amount of the tokens that have been deposited.
     * @param _data   Additional transaction data.
     */
    function tokenFallback(address, uint256, bytes) {}
}

contract token is ownable {
    using SafeMath for uint;
    
    token_database public db;
    
    event Transfer(address indexed from, address indexed to, uint indexed value, bytes data);
    event Donation(string _donor, string recipient);
    event Burn(address indexed _burner, uint256 indexed _amount);

    
     /**
     * @dev ERC223 standard `transfer` function to send tokens.
     * @param _to     The address to which the tokens will be sent.
     * @param _value  The amount of tokens to send.
     * @param _data   Additional token transaction data.
     */
    function transfer(address _to, uint _value, bytes _data)
    {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        
        db.increase_balance(_to, _value);
        db.decrease_balance(msg.sender, _value);
        
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
    }   
    
     /**
     * @dev ERC223 standard `transfer` function to send tokens.
     * @param _to     The address to which the tokens will be sent.
     * @param _value  The amount of tokens to send.
     */
    function transfer(address _to, uint _value)
    {
        uint codeLength;
        
        // Assign an empty _data if the parameter was not specified.
        bytes memory _empty;

        assembly {
            codeLength := extcodesize(_to)
        }
        
        db.increase_balance(_to, _value);
        db.decrease_balance(msg.sender, _value);
        
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            
            receiver.tokenFallback(msg.sender, _value, _empty);
        }
        Transfer(msg.sender, _to, _value, _empty);
    }
    
     /**
     * @dev Submit an official donation.
     * @param _to         The address to which the tokens will be sent (donated).
     * @param _value      The amount of tokens to send (donate).
     * @param _data       Additional token transaction data.
     * @param _donor      String name of the donor that will be anchored
     *                    to the blockchain.
     * @param _recipient  String name of the recipient that will be anchored
     *                    to the blockchain.
     */
    function donate(address _to, uint _value, bytes _data, string _donor, string _recipient)
    {
        transfer(_to, _value, _data);
        Donation(_donor, _recipient);
    }
    
     /**
     * @dev Getter function to retrieve a balance of the given address.
     * @param _owner     The address whose balance we want to know.
     * @return _balance  Balance of the given address.
     */
    function balanceOf(address _owner) constant returns (uint _balance)
    {
        return db.balanceOf(_owner);
    }
    
    /**
    * @dev Getter function to retrieve a total supply of Give Tokens.
    * @return _supply  Total amount of Give Tokens.
    */
    function totalSupply() constant returns (uint _supply)
    {
        return db.totalSupply();
    }
    
    /**
    * @dev Getter function to retrieve a name of the token.
    * @return Token name.
    */
    function name() constant returns (string)
    {
        // Hardcoded value because of there is no possibility of returning
        // string variables from `token_database` contract.
        return "Test GiveCoin";
    }
    
    /**
    * @dev Getter function to retrieve a symbol of the token.
    * @return Token symbol.
    */
    function symbol() constant returns (string)
    {
        // Hardcoded value because of there is no possibility of returning
        // string variables from `token_database` contract.
        return "Test GC";
    }
    
    /**
    * @dev Getter function to retrieve token decimals.
    * @return Token decimals.
    */
    function decimals() constant returns (uint8)
    {
        return db.decimals();
    }
    
    
    /** DEBUGGING FUNCTIONS **/
     
    
    /**
    * @dev Debugging function that allows owner to connect the token logic contract with
    *      state storage contract.
    */
    function configure(address _state_storage) only_owner
    {
        db = token_database(_state_storage);
    }
}
