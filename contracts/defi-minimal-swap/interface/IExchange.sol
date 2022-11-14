// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExchange {
    function ethToTokenSwap(uint256 expectedTokenAmount) external payable;

    function ethToTokenTransfer(uint256 expectedTokenAmount, address recipient) external payable;
}
