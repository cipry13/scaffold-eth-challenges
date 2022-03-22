pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() external payable {
    require(msg.value > 0, "ETH ammount must be greater than 0");

    uint256 amountOfTokens = msg.value * tokensPerEth;

    (bool sent) = yourToken.transfer(msg.sender, amountOfTokens);
    require(sent, "Token transfer failed");

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  function sellTokens(uint256 amountOfTokens) external {
    require(amountOfTokens > 0, "Tokens amount must be greater than 0");

    uint256 amountOfEth = amountOfTokens / tokensPerEth;

    (bool sent) = yourToken.transferFrom(msg.sender, address(this), amountOfTokens);
    require(sent, "Token transfer failed");

    (sent,) = msg.sender.call{value: amountOfEth}("");
    require(sent, "Eth send failed");
  }

  function withdraw() external onlyOwner {
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to withdraw");
  }
}
