import { expect } from "chai";
import { ethers } from "hardhat";
import { MyToken } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("MyToken", function () {
  let token: MyToken;
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  const NAME = "MyToken";
  const SYMBOL = "MTK";
  const SUPPLY = ethers.parseEther("1000000"); // 1 million tokens

  beforeEach(async function () {
    [owner, alice, bob] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("MyToken");
    token = await Token.deploy(NAME, SYMBOL, 18, SUPPLY);
  });

  // --- Déploiement ---
  describe("Deployment", function () {
    it("should set name, symbol and decimals correctly", async function () {
      // TODO A : Vérifier name, symbol et decimals
      expect(await token.name()).to.equal(NAME);
      expect(await token.symbol()).to.equal(SYMBOL);
      expect(await token.decimals()).to.equal(18);
    });

    it("should mint initial supply to owner", async function () {
      // TODO B : Vérifier totalSupply == SUPPLY et balanceOf(owner) == SUPPLY
      expect(await token.totalSupply()).to.equal(SUPPLY);
      expect(await token.balanceOf(owner.address)).to.equal(SUPPLY);
    });
  });

  // --- Transfer ---
  describe("transfer()", function () {
    it("should transfer tokens and emit Transfer event", async function () {
      const amount = ethers.parseEther("100");
      // TODO C : Vérifier l'événement Transfer + les balances après
      await expect(token.transfer(alice.address, amount))
        .to.emit(token, "Transfer")
        .withArgs(owner.address, alice.address, amount);

      expect(await token.balanceOf(owner.address)).to.equal(SUPPLY - amount);
      expect(await token.balanceOf(alice.address)).to.equal(amount);
    });

    it("should revert with InsufficientBalance if sender has not enough", async function () {
      // TODO D : alice essaie de transférer mais n'a rien
      // Utiliser revertedWithCustomError
      await expect(token.connect(alice).transfer(bob.address, 1n))
        .to.be.revertedWithCustomError(token, "InsufficientBalance")
        .withArgs(0n, 1n);
    });

    it("should revert with ZeroAddress if recipient is address(0)", async function () {
      // TODO E
      await expect(token.transfer(ethers.ZeroAddress, 1n))
        .to.be.revertedWithCustomError(token, "ZeroAddress");
    });
  });

  // --- Approve / TransferFrom ---
  describe("approve() and transferFrom()", function () {
    it("should allow transferFrom after approve", async function () {
      // TODO F : owner approve alice pour 500 tokens
      //          alice transferFrom owner vers bob
      //          Vérifier les balances et l'allowance restante
      const approvedAmount = ethers.parseEther("500");
      const transferredAmount = ethers.parseEther("200");

      await token.approve(alice.address, approvedAmount);
      await token
        .connect(alice)
        .transferFrom(owner.address, bob.address, transferredAmount);

      expect(await token.balanceOf(owner.address)).to.equal(
        SUPPLY - transferredAmount,
      );
      expect(await token.balanceOf(bob.address)).to.equal(transferredAmount);
      expect(await token.allowance(owner.address, alice.address)).to.equal(
        approvedAmount - transferredAmount,
      );
    });

    it("should revert if allowance exceeded", async function () {
      // TODO G
      const approvedAmount = ethers.parseEther("100");
      const requestedAmount = ethers.parseEther("101");

      await token.approve(alice.address, approvedAmount);

      await expect(
        token
          .connect(alice)
          .transferFrom(owner.address, bob.address, requestedAmount),
      )
        .to.be.revertedWithCustomError(token, "InsufficientAllowance")
        .withArgs(approvedAmount, requestedAmount);
    });

    it("should support infinite approval (uint256.max)", async function () {
      // TODO H : approve avec ethers.MaxUint256, vérifier que l'allowance
      //          ne diminue pas après transferFrom
      const amount = ethers.parseEther("100");

      await token.approve(alice.address, ethers.MaxUint256);
      await token
        .connect(alice)
        .transferFrom(owner.address, bob.address, amount);

      expect(await token.allowance(owner.address, alice.address)).to.equal(
        ethers.MaxUint256,
      );
    });
  });

  // --- Mint / Burn ---
  describe("mint() and burn()", function () {
    it("owner can mint additional tokens", async function () {
      // TODO I
      const amount = ethers.parseEther("100");

      await expect(token.mint(alice.address, amount))
        .to.emit(token, "Transfer")
        .withArgs(ethers.ZeroAddress, alice.address, amount);

      expect(await token.balanceOf(alice.address)).to.equal(amount);
      expect(await token.totalSupply()).to.equal(SUPPLY + amount);
    });

    it("non-owner cannot mint", async function () {
      // TODO J : alice essaie de minter — doit revert Unauthorized()
      await expect(token.connect(alice).mint(alice.address, 1n))
        .to.be.revertedWithCustomError(token, "Unauthorized");
    });

    it("any user can burn their own tokens", async function () {
      // TODO K
      const receivedAmount = ethers.parseEther("100");
      const burnedAmount = ethers.parseEther("40");

      await token.transfer(alice.address, receivedAmount);

      await expect(token.connect(alice).burn(burnedAmount))
        .to.emit(token, "Transfer")
        .withArgs(alice.address, ethers.ZeroAddress, burnedAmount);

      expect(await token.balanceOf(alice.address)).to.equal(
        receivedAmount - burnedAmount,
      );
      expect(await token.totalSupply()).to.equal(SUPPLY - burnedAmount);
    });
  });
});