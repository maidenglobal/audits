pragma solidity ^0.4.11;

contract ownable
{
    address public owner = msg.sender;
    
    function replace_owner(address _new_owner) only_owner
    {
        owner = _new_owner;
    }
    
    modifier only_owner
    {
        require (msg.sender == owner);
        _;
    }
    
}
