pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() external payable {
    uint256 amountOfTokensToBuy = msg.value * tokensPerEth;

    (bool sent) = yourToken.transfer(msg.sender, amountOfTokensToBuy);
    require(sent, "Token buy failed");

    emit BuyTokens(msg.sender, msg.value, amountOfTokensToBuy);
  }

  function sellTokens(uint256 amountOfTokensToSell) external {
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), amountOfTokensToSell);
    require(sent, "Token transfer failed");

    uint256 amountOfEth = amountOfTokensToSell / tokensPerEth;
    (sent,) = msg.sender.call{value: amountOfEth}("");
    require(sent, "Eth send failed");
  }

  function withdraw() external onlyOwner {
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to withdraw owner balance");
  }
}
