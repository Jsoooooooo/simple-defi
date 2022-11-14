pragma solidity ^0.8.0;
import "../interfaces/IUniswapV2Pair.sol";
import "./SafeMath.sol";
import "../error/ErrorReporter.sol";

contract SwapLibrary {
    using SafeMath for uint;

    // if the tokens weren't sorted, it would result in a distinct pair address for each sort order:
    function sortTokens(address tokenA, address tokenB) internal pure returns
    (address token0,address token1){
       if (tokenA == tokenB) revert ErrorReporter.SWAP_IDENTICAL_TOKEN_ADDRESS();
        (token0,token1) = tokenA > tokenB ? (token0,token1):(token1,token0);
        if (token0 == address(0)) revert ErrorReporter.SWAP_ZERO_ADDRESS();
    }

//    function getReserves(address factory,address tokenA, address tokenB) internal view returns
//    (uint reserveA,uint reserveB){
//        (address tokenA,) = sortTokens(tokenA,tokenB);
//        (uint reserve0, uint reserve1) = IUniswapV2Pair(pairFor(factory,tokenA,tokenB)).getReserves();
//        (reserveA,reserveB) = tokenA == token0 ? (reserve0,reserve1) : (reserve1,reserve0);
//    }


}
