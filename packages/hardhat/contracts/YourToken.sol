pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YourToken is ERC20 {
    constructor() ERC20("Gold", "GLD") {
        _mint(0x0540aDa197EBa2530d2c91129006D5bd5D28F408, 1000 * 10 ** 18);
    }
}
