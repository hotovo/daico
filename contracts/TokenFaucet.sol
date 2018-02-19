pragma solidity ^0.4.18;

import "./FractionalERC20.sol";

contract TokenFaucet {

  FractionalERC20 public token;

  function TokenFaucet(FractionalERC20 _token) public {
    token = _token;
  }

  function get100() public {
    token.transfer(msg.sender, 100);
  }

}