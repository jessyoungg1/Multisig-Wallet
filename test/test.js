const { expect } = require("chai");
const { ethers } = require("hardhat");
var Web3 = require('web3');

describe("Multisig Wallet", function () {
  it("Check variables set on deployment are correct", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Wallet = await ethers.getContractFactory("Wallet");
    const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
    await wallet.deployed();

    //expect(await wallet.owners.length).to.equal(3)
    expect(await wallet.owners(0)).to.equal(owner.address)
    expect(await wallet.owners(1)).to.equal(addr1.address)
    expect(await wallet.owners(2)).to.equal(addr2.address)

    expect(await wallet.limit()).to.equal(2);
  });
  it("Check deposit + balance of wallet", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
      await wallet.deployed();

      const beforeBalance = await wallet.getBalance();
      await expect(beforeBalance).to.equal(0);

      await wallet.deposit({value: "1000000000000000000"});

      const ETHAfter = await Web3.utils.fromWei("1000000000000000000", "ether")
      await expect(Number(ETHAfter)).to.equal(1);
  });
  it("Create Transfer", async function () {
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();

      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
      await wallet.deployed();

      await wallet.deposit({value: "1000000000000000000"});

      await wallet.createTransfer(addr3.address, 100)

      const requests = await wallet.transferRequests(0)

      await expect(requests.to).to.equal(addr3.address)
      await expect(requests.amount).to.equal(100)
      await expect(requests.approved).to.equal(false)
  })

  it("An address which is not the owner cant approve the transaction", async function () {
      const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();

      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
      await wallet.deployed();

      await wallet.deposit({value: "1000000000000000000"});
      await wallet.createTransfer(addr3.address, 100)

      await expect(wallet.connect(addr4).approve(0)).to.be.reverted
    })

  it("Approve a transaction", async function () {
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();

      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
      await wallet.deployed();

      await wallet.deposit({value: "1000000000000000000"});
      await wallet.createTransfer(addr3.address, 100)

      await wallet.approve(0);
      const approved = await wallet.approvals(owner.address,0);
      
      await expect(approved).to.equal(true);
  })

  it("Approve transaction reverted - already been approved by this address", async function () {
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();

      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
      await wallet.deployed();

      await wallet.deposit({value: "1000000000000000000"});
      await wallet.createTransfer(addr3.address, 100)

      await wallet.approve(0);
      const approved = await wallet.approvals(owner.address,0);
      await expect(approved).to.equal(true);

      await expect(wallet.approve(0)).to.be.revertedWith("Transfer already approved by this address")
  })
  it("Check number of approvals", async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const Wallet = await ethers.getContractFactory("Wallet");
    const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
    await wallet.deployed();

    await wallet.deposit({value: "1000000000000000000"});
    await wallet.createTransfer(addr3.address, 100)
    await wallet.approve(0);

    const calc = await wallet.compute(0);
    const calcNumber = Number(calc);
    await expect(calcNumber).to.equal(1);
  })
  it("Do final approval for transaction", async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const Wallet = await ethers.getContractFactory("Wallet");
    const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
    await wallet.deployed();

    await wallet.deposit({value: "1000000000000000000"});
    await wallet.createTransfer(addr3.address, "1000000000000000000")
    await wallet.approve(0);

    const calc = await wallet.compute(0);
    const calcNumber = Number(calc);
    await expect(calcNumber).to.equal(1);

    const balanceBeforeApproval = await ethers.provider.getBalance(addr3.address)
    console.log("Receiving wallets balance before approval: ", balanceBeforeApproval);

    await expect(wallet.connect(addr1).approve(0)).to.emit(wallet, "TransferApproved").withArgs(0);
    const numberOfApprovals = await wallet.compute(0);
    await expect(numberOfApprovals).to.equal(2);

    const balanceAfterApproval = await ethers.provider.getBalance(addr3.address)
    console.log("Receiving wallets balance after approval: ", balanceAfterApproval);
  })
  it("Expect rejection - Transfer already approved", async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const Wallet = await ethers.getContractFactory("Wallet");
    const wallet = await Wallet.deploy(addr1.address, addr2.address, 2);
    await wallet.deployed();

    await wallet.deposit({value: "1000000000000000000"});
    await wallet.createTransfer(addr3.address, "1000000000000000000")
    await wallet.approve(0);
    await wallet.connect(addr1).approve(0)

    //const one = wallet.transferRequests(0)
    //console.log(await wallet.transferRequests(0))
    await expect(wallet.connect(addr2).approve(0)).to.be.revertedWith("Transfer already approved");
  })

})