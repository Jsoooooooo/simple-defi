// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    error TRANSFER_FAILED();
    error STAKING_MORE_THAN_ZERO();
contract Staking is ReentrancyGuard {

    IERC20 public s_stakingToken; // record
    IERC20 public s_rewardToken;

    // how much each address deposited
    mapping(address=>uint256) public s_balances;
    // mapping of how much each address has been paid per second
    mapping(address=>uint256) public s_userRewardPerTokenPaid;
    // how much each user has earned
    mapping(address => uint256) public s_rewards;

    uint256 public s_totalSupply; // staking_token的总量
    uint256 public s_rewardPerToken; // 每人每秒奖励的token量
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100; // 每秒钟奖励100个token

    constructor (address stakingToken,address rewardToken){
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }
    // do we allow any tokens to stake
    function stake(uint256 _amount
    // address token need chainlink to convert price
    )
    updateReward(msg.sender)
    More_THAN_ZERO(_amount)
    nonReentrant
    external {
        // keep track of how much this user has staked
        s_balances[msg.sender] = s_balances[msg.sender] + _amount;
        // track how much token we have
        s_totalSupply = s_totalSupply + _amount;
        // transfer the token to contract
        bool success = s_stakingToken.transferFrom(msg.sender,address(this),_amount);
        if (!success) revert TRANSFER_FAILED();
    }

    function withdraw(uint256 _amount)
    nonReentrant
    updateReward(msg.sender)
    More_THAN_ZERO(_amount)
    external {
        s_balances[msg.sender] = s_balances[msg.sender] - _amount;
        s_totalSupply = s_totalSupply - _amount;
        bool success = s_stakingToken.transfer(msg.sender,_amount);
        if (!success) revert TRANSFER_FAILED();
    }

    function claimReward()
    nonReentrant
    updateReward(msg.sender)
    external {
        uint256 reward= s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender,reward);
        if (!success) revert TRANSFER_FAILED();
    }

    function rewardPerToken() public view returns (uint256){
        if (s_totalSupply == 0){
            return s_rewardPerToken;
        }else{
            // 前值  + 每秒per Token分发的量
            return s_rewardPerToken + (((block.timestamp-s_lastUpdateTime)*REWARD_RATE * 1e18)/s_totalSupply);
        }
    }

    function earned(address account) public view returns (uint256) {
        return
        ((s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account])) /
        1e18) + s_rewards[account];
    }

    modifier updateReward(address account){
        // 获取每秒每个token 分发值
        s_rewardPerToken = rewardPerToken();
        // 更新timeStamp
        s_lastUpdateTime = block.timestamp;
        // 计算该account已经赚取的amount
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerToken;
        _;
    }

    modifier More_THAN_ZERO(uint256 amount){
        if (amount == 0) revert STAKING_MORE_THAN_ZERO();
        _;
    }

    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }
}
