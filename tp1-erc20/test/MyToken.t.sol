// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    uint256 SUPPLY = 1_000_000 ether;

    function setUp() public {
        vm.prank(owner);
        token = new MyToken("MyToken", "MTK", 18, SUPPLY);
        excludeSender(owner);
    }

    // --- Tests unitaires ---
    function test_InitialState() public view {
        // TODO 1 : Vérifier name, symbol, decimals, totalSupply, balanceOf[owner]
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(owner), SUPPLY);
    }

    function test_Transfer() public {
        uint256 amount = 100 ether;
        vm.prank(owner);
        // TODO 2 : Transférer et vérifier les balances
        token.transfer(alice, amount);

        assertEq(token.balanceOf(owner), SUPPLY - amount);
        assertEq(token.balanceOf(alice), amount);
    }

    function test_RevertIf_InsufficientBalance() public {
        // TODO 3 : Utiliser vm.expectRevert avec l'erreur custom encodée
        // vm.expectRevert(abi.encodeWithSelector(MyToken.InsufficientBalance.selector, 0, 1 ether))
        vm.expectRevert(
            abi.encodeWithSelector(
                MyToken.InsufficientBalance.selector,
                0,
                1 ether
            )
        );
        vm.prank(alice);
        token.transfer(bob, 1 ether);
    }

    // --- Tests de fuzzing ---
    /// @notice Le fuzzing génère 256 valeurs aléatoires pour (to, amount)
    function testFuzz_TransferConservesTotalSupply(
        address to,
        uint256 amount
    ) public {
        // TODO 4 : Filtrer les cas invalides avec vm.assume
        // vm.assume(to != address(0) && to != owner)
        // Borner amount : amount = bound(amount, 0, SUPPLY)
        // Vérifier que totalSupply reste identique après le transfert
        vm.assume(to != address(0) && to != owner);
        amount = bound(amount, 0, SUPPLY);
        uint256 supplyBefore = token.totalSupply();

        vm.prank(owner);
        token.transfer(to, amount);

        assertEq(token.totalSupply(), supplyBefore);
    }

    function testFuzz_ApproveAndTransferFrom(
        uint256 approveAmt,
        uint256 transferAmt
    ) public {
        // TODO 5 : Fuzzing sur approve + transferFrom
        // Si transferAmt > approveAmt → doit revert
        // Si transferAmt <= approveAmt → doit réussir
        approveAmt = bound(approveAmt, 0, SUPPLY);
        transferAmt = bound(transferAmt, 0, SUPPLY);

        vm.prank(owner);
        token.approve(alice, approveAmt);

        if (transferAmt > approveAmt) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    MyToken.InsufficientAllowance.selector,
                    approveAmt,
                    transferAmt
                )
            );
            vm.prank(alice);
            token.transferFrom(owner, bob, transferAmt);
        } else {
            vm.prank(alice);
            token.transferFrom(owner, bob, transferAmt);

            assertEq(token.balanceOf(owner), SUPPLY - transferAmt);
            assertEq(token.balanceOf(bob), transferAmt);
            assertEq(
                token.allowance(owner, alice),
                approveAmt - transferAmt
            );
        }
    }

    // --- Invariants ---
    /// @notice Foundry appellera cet invariant après chaque séquence d'actions
    function invariant_totalSupplyIsConsistent() public view {
        // TODO 6 : Vérifier que totalSupply == balanceOf[owner] + balanceOf[alice] + ...
        // Pour un invariant simple : assertEq(token.totalSupply(), SUPPLY); // pas de mint/burn dans ce test
        // (Pour un invariant complet il faudrait un Handler, voir la documentation Foundry)
        assertEq(token.totalSupply(), SUPPLY);
    }
}
