pragma solidity ^0.8.0;
import "../error/ErrorReporter.sol";
import "./Exchange.sol";

contract Factory {
    mapping(address => address) public exchanges;

    /**
     * Create Exchange Market
     * tokenAddress that creates a new exchange
     * return address of new exchange token/eth
     */
    function createExchange(address tokenAddress) public returns (address exchangeAddress) {
        if (tokenAddress == address(0)) revert ErrorReporter.TOKEN_ADDRESS_NOT_VALID();
        if (exchanges[tokenAddress] != address(0)) revert ErrorReporter.EXCHANGE_EXISTED();

        // create new exchange market
        Exchange exchange = new Exchange(tokenAddress);
        // record the new exchange into the map exchanges
        exchanges[tokenAddress] = address(exchange);
        exchangeAddress = address(exchange);
    }

    function getExchange(address tokenAddress) public view returns (address exchangeAddress){
        exchangeAddress = exchanges[tokenAddress];
        if (exchangeAddress == address(0)) revert ErrorReporter.EXCHANGE_NOT_EXIST();
    }
}
