pragma solidity ^0.8.0;

interface IRewardToken {
    function mint(address account, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external;
}
