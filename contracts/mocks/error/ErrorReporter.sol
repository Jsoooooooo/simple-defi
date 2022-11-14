// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorReporter {
   error APPROVE_FAILED();
   error TRANSFER_FAILED();
   error TRANSFER_FROM_FAILED();
   error ETH_TRANSFER_FAILED();

   // defi-minimal-swap && Factory
   error SWAP_IDENTICAL_TOKEN_ADDRESS();
   error SWAP_ZERO_ADDRESS();
   error TOKEN_ADDRESS_NOT_VALID();
   error EXCHANGE_NOT_EXIST();
   error EXCHANGE_EXISTED();

   // exchange
   error INVALID_TOKEN_ADDRESS();

}
