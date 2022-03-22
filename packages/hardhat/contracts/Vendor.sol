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
    require(msg.value > 0, "ETH ammount must be greater than 0 to buy");

    uint256 amountOfTokensToBuy = msg.value * tokensPerEth;

    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountOfTokensToBuy, "Vendor doesn't have enough tokens to buy");

    (bool sent) = yourToken.transfer(msg.sender, amountOfTokensToBuy);
    require(sent, "Token buy failed");

    emit BuyTokens(msg.sender, msg.value, amountOfTokensToBuy);
  }

  function sellTokens(uint256 amountOfTokensToSell) external {
    require(amountOfTokensToSell > 0, "Tokens amount must be greater than 0 to sell");

    uint256 senderBalance = yourToken.balanceOf(msg.sender);
    require(senderBalance >= amountOfTokensToSell, "Your balance doesn't have enough tokens to sell");

    uint256 amountOfEth = amountOfTokensToSell / tokensPerEth;
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), amountOfTokensToSell);
    require(sent, "Token transfer failed");

    (sent,) = msg.sender.call{value: amountOfEth}("");
    require(sent, "Eth send failed");
  }

  function withdraw() external onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has no balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to withdraw owner balance");
  }
}
