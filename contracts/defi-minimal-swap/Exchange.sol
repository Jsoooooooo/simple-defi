// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IFactory.sol";
import "./interface/IExchange.sol";
import "../../mocks/error/ErrorReporter.sol";

contract Exchange is ERC20{
    address public tokenAddress;
    address public factoryAddress;


    event TokenPurchase(address indexed buyer, uint256 indexed ethSold, uint256 tokenBought);
    event EthPurchase(address indexed buyer, uint256 indexed tokenSold, uint256 ethBought);
    event AddLiquidity(address indexed provider, uint256 indexed ethAmount, uint256 indexed tokenAmount);
    event RemoveLiquidity(address indexed provider, uint256 indexed ethAmount, uint256 indexed tokenAmount);

    constructor(address token) ERC20("JCSwap","JC"){
        if (token == address(0)) revert ErrorReporter.INVALID_TOKEN_ADDRESS();
        tokenAddress = token;
        factoryAddress = msg.sender;
    }

    function addPoolLiquidity(uint256 _amount) public payable returns(uint256 poolTokenAmount){
        // get the amount of token and eth in the contract
        (uint256 tokenReserve,uint256 ethReserve) = getReserves();
        // if the tokenAmount is zero, then the ethAmount available for trade is the amount of eth
        if(tokenReserve == 0){
            IERC20 token = IERC20(tokenAddress);
            token.transferFrom(msg.sender,address(this),_amount);
            poolTokenAmount = ethReserve;
        } else{
            ethReserve = ethReserve - msg.value;
            // expected amount based on the current reserve ratio tokenReserve / ethReserve
            uint256 expectedTokenAmount = (msg.value * tokenReserve) / ethReserve;
            require(_amount >= expectedTokenAmount, "Insufficient token amount");
            IERC20 token = IERC20(tokenAddress);
            token.transferFrom(msg.sender, address(this), expectedTokenAmount);
            poolTokenAmount = (totalSupply() * msg.value) / ethReserve;
        }
        _mint(msg.sender, poolTokenAmount);
        emit AddLiquidity(msg.sender, msg.value, _amount);
    }

    function removePoolLiquidity(uint256 poolTokenAmount)
    public
    returns (uint256 ethAmount, uint256 tokenAmount)
    {
        require(poolTokenAmount > 0, "Amount of pool token cannot be 0");
        // Retrieve reserves
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();

        // calculate the amount of Token & ETH based on the ratio
        ethAmount = (ethReserve * poolTokenAmount) / totalSupply();
        tokenAmount = (tokenReserve * poolTokenAmount) / totalSupply();

        // reduce supply of pool tokens
        _burn(msg.sender, poolTokenAmount);
        // returns ETH & Token to the liquidity provider
        (bool sent, ) = (msg.sender).call{value: ethAmount}("");
        require(sent, "Failed to send Ether");
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
    }

    function getReserves() public view returns(uint256 tokenReserve,uint256 ethReserve){
        // query the token amount of the user inputs locked in the contract
        tokenReserve = IERC20(tokenAddress).balanceOf(address(this));
        // querying the eth token amount locked in the contract
        ethReserve = address(this).balance;
    }

    function getAmount(
        uint256 sellAmount, // amount of token1 selling
        uint256 sellReserve, // reserve of token1 selling
        uint256 buyReserve // reserve of token2 buying
    ) private pure returns (uint256 buyAmount) {
        //  fees taken intout account. 0,3 % fees . 0,3 % = 3/1000. Fees removed from `sellAmount`
        require(sellReserve > 0 && buyReserve > 0, "Reserves cannot be null");

        //  exchangeRate = buyReserve / (sellReserve + sellAmountWithFee)
        //  buyAmount = exchangeRate * sellAmountWithFee

        // calculate the total sell amount deducted by transaction fee
        uint256 sellAmountWithFee = sellAmount * 997;
        uint256 numerator = sellAmountWithFee * buyReserve;
        // calculate total amount of sell token reserved in the contract
        uint256 denominator = (1000 * sellReserve + sellAmountWithFee);
        buyAmount = numerator / denominator;
    }

    // by inputting ethAmount, calculating the relative token amount
    function getTokenAmount(uint256 ethAmount) public view returns(uint256 tokenAmount){
        require(ethAmount > 0, "Eth amount cannot be null");
        // get tokenAmount
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();
        tokenAmount = getAmount(ethAmount, ethReserve, tokenReserve);
    }

    // by inputting tokenAmount, calculating the relative eth amount
    function getEthAmount(uint256 tokenAmount) public view returns (uint256 ethAmount) {
        require(tokenAmount > 0, "Token amount cannot be null");
        // Retrieve reserves
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();
        // Trading tokenAmount for ethAmount (= Sell Token for Eth)
        ethAmount = getAmount(tokenAmount, tokenReserve, ethReserve);
    }

    // transfer ethers to token
    function ethToToken(uint256 expectedTokenAmount, address recipient) private {
        // Retrieve reserves
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();
        uint256 tokenAmount = getAmount(msg.value, ethReserve - msg.value, tokenReserve);
        require(tokenAmount >= expectedTokenAmount, "Token Amount low");
        IERC20(tokenAddress).transfer(recipient, tokenAmount);
        emit TokenPurchase(recipient, msg.value, tokenAmount);
    }

    function ethToTokenSwap(uint256 expectedTokenAmount) public payable {
        ethToToken(expectedTokenAmount, msg.sender);
    }

    function ethToTokenTransfer(uint256 expectedTokenAmount, address recipient) public payable {
        ethToToken(expectedTokenAmount, recipient);
    }

    //expectedEthAmount uint256: Expected amount of ETH to be received by the user
    function tokenToEthSwap(uint256 tokenAmount, uint256 expectedEthAmount) public {
        // Retrieve reserves
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();
        uint256 ethAmount = getAmount(tokenAmount, tokenReserve, ethReserve);
        require(ethAmount >= expectedEthAmount, "Eth Amount low");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
        (bool sent, ) = (msg.sender).call{value: ethAmount}("");
        require(sent, "Failed to send Ether");
        emit EthPurchase(msg.sender, tokenAmount, ethAmount);
    }

    function tokenToTokenSwap(
        uint256 tokenAmount,
        uint256 expectedTargetTokenAmount,
        address targetTokenAddress
    ) public {
        require(targetTokenAddress != address(0), "Token address not valid");
        require(tokenAmount > 0, "Tokens amount not valid");
        address targetExchangeAddress = IFactory(factoryAddress).getExchange(targetTokenAddress);
        require(
            targetExchangeAddress != address(this) && targetExchangeAddress != address(0),
            "Exchange address not valid"
        );

        // Retrieve reserves
        (uint256 tokenReserve, uint256 ethReserve) = getReserves();
        uint256 ethAmount = getAmount(tokenAmount, tokenReserve, ethReserve);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);

        IExchange(targetExchangeAddress).ethToTokenTransfer{value: ethAmount}(
            expectedTargetTokenAmount,
            msg.sender
        );
    }
}
