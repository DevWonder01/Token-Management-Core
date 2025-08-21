// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol"; // For _msgSender()

/**
 * @title AdvancedERC20Token
 * @dev An ERC20 token with enhanced functionalities:
 * Mint, Burn, Transfer (standard ERC20), Lock, Airdrop, Whitelist, and Blacklist.
 * Only the contract owner can perform privileged operations.
 */

contract SampleToken is ERC20, Ownable {
    // --- State Variables ---

    // Mapping to store locked token balances for each address
    mapping(address => uint256) private _lockedBalances;


    // Mapping to track whitelisted addresses
    mapping(address => bool) private _isWhitelisted;


    // Mapping to track blacklisted addresses
    mapping(address => bool) private _isBlacklisted;

  

    // --- Events ---

    event TokensLocked(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user, uint256 amount);
    event AirdropCompleted(
        address indexed caller,
        uint256 totalAmount,
        uint256 recipientCount
    );
    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);

    // --- Constructor ---

    /**
     * @dev Constructor to initialize the ERC20 token with a name and symbol.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param initialSupply_ The initial supply of tokens to mint and assign to the deployer.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_
    )
        ERC20(name_, symbol_)
        Ownable() // Set the deployer as the initial owner
    {
        _mint(msg.sender, initialSupply_); // Mint initial supply to the deployer
    }

    // --- Overridden ERC20 Functions for Lock/Blacklist Checks ---

    /**
     * @dev See {IERC20-transfer}.
     * Overridden to prevent transfers from blacklisted accounts
     * and ensure sufficient unlocked balance.
     */
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address sender = _msgSender();
        require(
            !_isBlacklisted[sender],
            "AdvancedERC20Token: sender is blacklisted"
        );
        require(
            balanceOf(sender) - _lockedBalances[sender] >= amount,
            "AdvancedERC20Token: not enough unlocked balance"
        );
        return super.transfer(to, amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     * Overridden to prevent transfers from blacklisted accounts
     * and ensure sufficient unlocked balance.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(
            !_isBlacklisted[from],
            "AdvancedERC20Token: sender is blacklisted"
        );
        require(
            balanceOf(from) - _lockedBalances[from] >= amount,
            "AdvancedERC20Token: not enough unlocked balance"
        );
        return super.transferFrom(from, to, amount);
    }

    /**
     * @dev Mints new tokens and assigns them to an account.
     * Only the contract owner can call this function.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(
            !_isBlacklisted[to],
            "AdvancedERC20Token: cannot mint to blacklisted address"
        );
        _mint(to, amount);
    }

    // --- Burning Functionality ---

    /**
     * @dev Burns tokens from the caller's account.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public virtual {
        address owner_ = _msgSender();
        require(
            !_isBlacklisted[owner_],
            "AdvancedERC20Token: cannot burn from blacklisted address"
        );
        require(
            balanceOf(owner_) - _lockedBalances[owner_] >= amount,
            "AdvancedERC20Token: cannot burn locked tokens"
        );
        _burn(owner_, amount);
    }

    /**
     * @dev Burns tokens from the `account`'s balance by `spender`.
     * @param account The account from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        require(
            !_isBlacklisted[account],
            "AdvancedERC20Token: cannot burn from blacklisted address"
        );
        require(
            balanceOf(account) - _lockedBalances[account] >= amount,
            "AdvancedERC20Token: cannot burn locked tokens"
        );
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    // --- Locking Functionality ---

    /**
     * @dev Locks a specified amount of tokens for a given user.
     * Only the contract owner can call this function.
     * Locked tokens cannot be transferred or burned.
     * @param user The address for whom to lock tokens.
     * @param amount The amount of tokens to lock.
     */
    function lock(address user, uint256 amount) public onlyOwner {
        require(
            user != address(0),
            "AdvancedERC20Token: lock to the zero address"
        );
        require(
            balanceOf(user) >= amount,
            "AdvancedERC20Token: Insufficient balance to lock"
        );

        _lockedBalances[user] += amount;
        emit TokensLocked(user, amount);
    }

    /**
     * @dev Unlocks a specified amount of tokens for a given user.
     * Only the contract owner can call this function.
     * @param user The address for whom to unlock tokens.
     * @param amount The amount of tokens to unlock.
     */
    function unlock(address user, uint256 amount) public onlyOwner {
        require(
            user != address(0),
            "AdvancedERC20Token: unlock from the zero address"
        );
        require(
            _lockedBalances[user] >= amount,
            "AdvancedERC20Token: not enough locked tokens to unlock"
        );

        _lockedBalances[user] -= amount;
        emit TokensUnlocked(user, amount);
    }

    /**
     * @dev Returns the amount of tokens locked for a specific user.
     * @param user The address to query the locked balance for.
     * @return The amount of locked tokens.
     */
    function lockedBalanceOf(address user) public view returns (uint256) {
        return _lockedBalances[user];
    }

    /**
     * @dev Returns the amount of unlocked tokens for a specific user.
     * @param user The address to query the unlocked balance for.
     * @return The amount of unlocked tokens.
     */
    function unlockedBalanceOf(address user) public view returns (uint256) {
        return balanceOf(user) - _lockedBalances[user];
    }

    // --- Airdrop Functionality ---

    /**
     * @dev Performs an airdrop of tokens to multiple recipients.
     * Only the contract owner can call this function.
     * Mints new tokens for each recipient.
     * @param recipients An array of addresses to receive tokens.
     * @param amounts An array of amounts corresponding to each recipient.
     */
    function airdrop(address[] calldata recipients, uint256[] calldata amounts)
        public
        onlyOwner
    {
        require(
            recipients.length == amounts.length,
            "AdvancedERC20Token: Arrays must have same length"
        );
        uint256 totalAirdropAmount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];

            require(
                recipient != address(0),
                "AdvancedERC20Token: Recipient cannot be the zero address"
            );
            require(
                !_isBlacklisted[recipient],
                "AdvancedERC20Token: Cannot airdrop to blacklisted address"
            );

            _mint(recipient, amount);
            totalAirdropAmount += amount;
        }
        emit AirdropCompleted(
            msg.sender,
            totalAirdropAmount,
            recipients.length
        );
    }

    // --- Whitelist Functionality ---

    /**
     * @dev Adds an address to the whitelist.
     * Only the contract owner can call this function.
     * @param account The address to add to the whitelist.
     */
    function addWhitelist(address account) public onlyOwner {
        require(
            account != address(0),
            "AdvancedERC20Token: Cannot whitelist the zero address"
        );
        require(
            !_isWhitelisted[account],
            "AdvancedERC20Token: Account is already whitelisted"
        );
        _isWhitelisted[account] = true;
        emit WhitelistAdded(account);
    }

    /**
     * @dev Removes an address from the whitelist.
     * Only the contract owner can call this function.
     * @param account The address to remove from the whitelist.
     */
    function removeWhitelist(address account) public onlyOwner {
        require(
            _isWhitelisted[account],
            "AdvancedERC20Token: Account is not whitelisted"
        );
        _isWhitelisted[account] = false;
        emit WhitelistRemoved(account);
    }

    /**
     * @dev Checks if an address is whitelisted.
     * @param account The address to check.
     * @return True if the account is whitelisted, false otherwise.
     */
    function isWhitelisted(address account) public view returns (bool) {
        return _isWhitelisted[account];
    }

    // --- Blacklist Functionality ---

    /**
     * @dev Adds an address to the blacklist.
     * Only the contract owner can call this function.
     * Blacklisted accounts cannot send, receive, or burn tokens.
     * @param account The address to add to the blacklist.
     */
    function addBlacklist(address account) public onlyOwner {
        require(
            account != address(0),
            "AdvancedERC20Token: Cannot blacklist the zero address"
        );
        require(
            !_isBlacklisted[account],
            "AdvancedERC20Token: Account is already blacklisted"
        );
        _isBlacklisted[account] = true;
        emit BlacklistAdded(account);
    }

    /**
     * @dev Removes an address from the blacklist.
     * Only the contract owner can call this function.
     * @param account The address to remove from the blacklist.
     */
    function removeBlacklist(address account) public onlyOwner {
        require(
            _isBlacklisted[account],
            "AdvancedERC20Token: Account is not blacklisted"
        );
        _isBlacklisted[account] = false;
        emit BlacklistRemoved(account);
    }

    /**
     * @dev Checks if an address is blacklisted.
     * @param account The address to check.
     * @return True if the account is blacklisted, false otherwise.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }
}
