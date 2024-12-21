// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingRewardsForScholarships {
    // Struct to hold user staking information
    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    address public owner;
    uint256 public rewardRate;  // Annual reward rate in percentage
    uint256 public scholarshipFund;
    uint256 public totalStaked;
    
    mapping(address => Stake) public stakes;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event ScholarshipFunded(uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _rewardRate) {
        owner = msg.sender;
        rewardRate = _rewardRate;
        scholarshipFund = 0;
        totalStaked = 0;
    }

    // Stake tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        
        // Update user's stake
        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].timestamp = block.timestamp;
        
        totalStaked += _amount;
        
        emit Staked(msg.sender, _amount);
    }

    // Unstake tokens
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Insufficient balance to unstake");
        
        // Update user's stake
        stakes[msg.sender].amount -= _amount;
        
        totalStaked -= _amount;
        
        emit Unstaked(msg.sender, _amount);
    }

    // Calculate rewards for a user
    function calculateReward(address _user) public view returns (uint256) {
        uint256 stakedAmount = stakes[_user].amount;
        uint256 stakingDuration = block.timestamp - stakes[_user].timestamp;  // Time in seconds
        uint256 reward = (stakedAmount * rewardRate * stakingDuration) / (365 days * 100);
        return reward;
    }

    // Claim rewards
    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");
        
        // Transfer the reward (can be in native tokens or a custom token)
        payable(msg.sender).transfer(reward);
        
        emit RewardClaimed(msg.sender, reward);
    }

    // Donate funds to the scholarship pool
    function donateToScholarship(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient contract balance");
        
        scholarshipFund += _amount;
        
        emit ScholarshipFunded(_amount);
    }

    // Get contract balance (for scholarship fund allocation)
    function getScholarshipFund() external view returns (uint256) {
        return scholarshipFund;
    }

    // Deposit funds into the contract (owner deposits for rewards)
    receive() external payable {}
}
