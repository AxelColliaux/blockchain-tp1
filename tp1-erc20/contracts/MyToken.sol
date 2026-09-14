// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

/// @title MyToken — Token ERC-20 pédagogique
/// @notice Implémentation complète à réaliser en TP1
contract MyToken is IERC20 {

    // ── Storage ────────────────────────────────────────────────────
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ── Erreurs custom ─────────────────────────────────────────────
    // TODO 1 : Déclarer les erreurs custom suivantes :
    //   - Unauthorized() : appelant non autorisé
    //   - InsufficientBalance(uint256 available, uint256 required)
    //   - InsufficientAllowance(uint256 available, uint256 required)
    //   - ZeroAddress() : transfert vers address(0)
    //   - ZeroAmount() : montant nul
    error Unauthorized();
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error ZeroAddress();
    error ZeroAmount();

    // ── Events supplémentaires ─────────────────────────────────────
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // ── Modificateurs ──────────────────────────────────────────────
    // TODO 2 : Déclarer le modifier onlyOwner
    //   qui reverte avec Unauthorized() si msg.sender != owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    // ── Constructor ────────────────────────────────────────────────
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        // TODO 3 : Initialiser name, symbol, decimals, owner (= msg.sender)
        // puis appeler _mint(msg.sender, _initialSupply)
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        _mint(msg.sender, _initialSupply);
    }

    // ── Fonctions ERC-20 publiques ─────────────────────────────────
    function transfer(
        address to,
        uint256 amount
    ) external returns (bool) {
        // TODO 4 : Vérifier to != address(0) (revert ZeroAddress)
        // puis appeler _transfer(msg.sender, to, amount)
        // retourner true
        if (to == address(0)) {
            revert ZeroAddress();
        }

        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) external returns (bool) {
        // TODO 5 : Vérifier spender != address(0)
        // Mettre à jour allowance[msg.sender][spender]
        // Émettre Approval(msg.sender, spender, amount)
        // retourner true
        if (spender == address(0)) {
            revert ZeroAddress();
        }

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        // TODO 6 : Implémenter transferFrom
        // 1. Vérifier to != address(0)
        // 2. Lire l'allowance :
        //    uint256 allowed = allowance[from][msg.sender]
        // 3. Si allowed != type(uint256).max (infinite approval) :
        //    vérifier allowed >= amount
        //    (revert InsufficientAllowance)
        //    puis décrémenter allowance[from][msg.sender]
        //    (avec unchecked)
        // 4. Appeler _transfer(from, to, amount)
        // 5. Retourner true
        if (to == address(0)) {
            revert ZeroAddress();
        }

        uint256 allowed = allowance[from][msg.sender];

        if (allowed != type(uint256).max) {
            if (allowed < amount) {
                revert InsufficientAllowance(allowed, amount);
            }

            unchecked {
                allowance[from][msg.sender] = allowed - amount;
            }
        }

        _transfer(from, to, amount);
        return true;
    }

    // ── Fonctions admin ────────────────────────────────────────────
    function mint(
        address to,
        uint256 amount
    ) external onlyOwner {
        // TODO 7 : Appeler _mint(to, amount)
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        // TODO 8 : Appeler _burn(msg.sender, amount)
        _burn(msg.sender, amount);
    }

    function transferOwnership(
        address newOwner
    ) external onlyOwner {
        // TODO 9 : Vérifier newOwner != address(0)
        // Émettre OwnershipTransferred(owner, newOwner)
        // Mettre à jour owner
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // ── Fonctions internes (FOURNIES — ne pas modifier) ───────────
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 bal = balanceOf[from];

        if (bal < amount) {
            revert InsufficientBalance(bal, amount);
        }

        unchecked {
            balanceOf[from] = bal - amount;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function _burn(
        address from,
        uint256 amount
    ) internal {
        uint256 bal = balanceOf[from];

        if (bal < amount) {
            revert InsufficientBalance(bal, amount);
        }

        unchecked {
            balanceOf[from] = bal - amount;
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}