pragma solidity ^0.4.11;

import './SafeMath.sol';
import './ownable.sol';
import './token_database.sol';
import './token.sol';

/**
 * @dev Provides a default implementation of an ICO contract that will be used to sell the specified amount of tokens
 * at the given price.
 */
contract ICO is ownable{
    using SafeMath for uint;
    
    event Buy(address indexed _owner, uint indexed _ETH, uint256 indexed _tokens);
    
    uint256 public start_timestamp = now;
    uint256 public end_timestamp = now + 28 days;
    uint256 public GiveCoins_per_ETH = 30000; // This means 300 GC per 1 ETH
    address public withdrawal_address = msg.sender;
    
    mapping (address => bool) muted;
    
    token public GiveCoin_token;
    
     /**
     * @dev Fallback function that will be called
     *      whenever someone wants to purchase tokens from the ICO
     */
    function() payable mutex(msg.sender) {
    // Mute sender to prevent it from calling function recursively
    
        if(block.timestamp > end_timestamp || block.timestamp < start_timestamp || msg.value < 10000000000000000)
        {
            throw;
        }
        
        uint256 reward = GiveCoins_per_ETH.mul( msg.value ) / 10**18;
        
        if(reward > GiveCoin_token.balanceOf(this))
        {
            uint256 _refund = (reward - GiveCoin_token.balanceOf(this)).mul(10**18) / GiveCoins_per_ETH;
            assert(msg.sender.send(_refund));
            reward = GiveCoin_token.balanceOf(this);
        }
        
        withdrawal_address.send(this.balance);
        GiveCoin_token.transfer(msg.sender, reward);
        Buy(msg.sender, msg.value, reward);
        
    }
    
     /**
     * @dev ERC223 standard `tokenFallback` function to handle incoming token transactions.
     * @param _addr   The address of the contract of the tokens that have been deposited.
     * @param _amount The amount of the tokens that have been deposited.
     * @param _data   Additional transaction data.
     */
    function tokenFallback(address _addr, uint256 _amount, bytes _data)
    {
        require(msg.sender == address(GiveCoin_token));
    }
    
    
     /**
     * @dev A function to suicide contract after the end of ICO.
     */
    function closeICO() only_owner
    {
        suicide(owner);
    }
    
     /** DEBUGGING FUNCTIONS **/
    
    
     /**
     * @dev Debugging function that allows owner to withdraw funds from the contract.
     */
    function withdraw() only_owner
    {
        owner.send(this.balance);
    }
    
     /**
     * @dev Debugging function that allows owner to adjust Give token price
     *      due to the high volatility of ETH. 
     * @param _new_price The amount of Give tokens that would be granted to
     *        contributor for each 10**18 WEI.
     *        _new_price should be equal to ETH/USD * 100 to set Give token
     *        price rate to 1 USD.
     */
    function adjust_price(uint256 _new_price) only_owner
    {
        GiveCoins_per_ETH = _new_price;
    }
    
     /**
     * @dev Debugging function that allows owner to set the end timestamp for the ICO.
     * @param _end_timestamp New timestamp when the ICO will close.
     */
    function change_end_timestamp(uint256 _end_timestamp) only_owner
    {
        end_timestamp = _end_timestamp;
    }
    
     /**
     * @dev Debugging function that allows owner to withdraw the specified amount
     *      of tokens from the ICO contract.
     * @param _amount Amount of tokens to withdraw.
     */
    function withdraw_tokens(uint256 _amount) only_owner
    {
        GiveCoin_token.transfer(owner, _amount);
    }
    
     /**
     * @dev Debugging function that allows owner to set the withdrawal address.
     * @param _withdrawal_address ETH will be sent to this address after purchasing tokens
     *        from the ICO contract.
     */
    function change_withdrawal_address(address _withdrawal_address) only_owner
    {
        withdrawal_address = _withdrawal_address;
    }
    
     /**
     * @dev Debugging function that allows owner to connect the ICO contract
     *      with Give Token contract and set the start and end timestamps.
     * @param _token_contract  Address of Give Token contract.
     * @param _start_timestamp New timestamp when the ICO will start.
     * @param _end_timestamp   New timestamp when the ICO will close.
     */
    function configure(address _token_contract, uint _start_timestamp, uint _end_timestamp) only_owner
    {
        GiveCoin_token = token(_token_contract);
        start_timestamp = _start_timestamp;
        end_timestamp = _end_timestamp;
    }
    
    // Mutex modifier to prevent re-entries
    modifier mutex(address _target)
    {
        if( muted[_target] )
        {
            throw;
        }
        muted[_target] = true;
        _;
        muted[_target] = false;
    }
}
