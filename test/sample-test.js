const expect = require("chai").expect;
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("mints", function () {
  it("Should mint the corresponding nfts to the senders", async function () {
    const [addr1, addr2, addr3] = await hre.ethers.getSigners();

    const UkranieCharity = await ethers.getContractFactory("UkranieCharity");
    const Contract = await UkranieCharity.deploy(
      "IStandWithUkranie",
      "ISWK",
      "https://sampleuri",
      "0x7ec7af8cff090c533dc23132286f33dd31d13e29"
    );
    await Contract.deployed();

    // Tier1 test
    const txn1 = await Contract.connect(addr1).donate({
      value: ethers.utils.parseEther("0.05"),
    });
    txn1.wait();
    const balanceOfAdd1 = await Contract.balanceOf(addr1.address, 1);
    expect(balanceOfAdd1).to.equal(1);

    // Tier 2 test
    const txn2 = await Contract.connect(addr2).donate({
      value: ethers.utils.parseEther("0.5"),
    });
    txn2.wait();
    const balanceOfAdd2nft1 = await Contract.balanceOf(addr2.address, 1);
    const balanceOfAdd2nft2 = await Contract.balanceOf(addr2.address, 2);
    expect(balanceOfAdd2nft2).to.equal(1);
    expect(balanceOfAdd2nft1).to.equal(1);

    // Tier 3 test
    const txn3 = await Contract.connect(addr3).donate({
      value: ethers.utils.parseEther("1.1"),
    });
    txn3.wait();
    const balanceOfAdd3nft1 = await Contract.balanceOf(addr2.address, 1);
    const balanceOfAdd3nft2 = await Contract.balanceOf(addr2.address, 2);
    const balanceOfAdd3nft3 = await Contract.balanceOf(addr2.address, 3);
    expect(balanceOfAdd3nft1).to.equal(1);
    expect(balanceOfAdd3nft2).to.equal(1);
    expect(balanceOfAdd3nft3).to.equal(1);
  });
});

describe("withdrawn", function () {
  it("Should withdrawn the corresponding amount to the sigWallet", async function () {
    const [add1, add2] = await hre.ethers.getSigners();

    const UkranieCharity = await ethers.getContractFactory("UkranieCharity");
    const Contract = await UkranieCharity.deploy(
      "IStandWithUkranie",
      "ISWK",
      "https://sampleuri",
      add1.address
    );
    await Contract.deployed();

    const dontateFunds = await Contract.connect(add1).donate({
      value: ethers.utils.parseEther("0.8"),
    });
    dontateFunds.wait();

    const donateFunds2 = await Contract.connect(add2).donate({
      value: ethers.utils.parseEther("1.3"),
    });
    donateFunds2.wait();
    const balance0fContract = await Contract.provider.getBalance(
      Contract.address
    );
    expect(balance0fContract).to.equal(2100000000000000000n);

    const withdrawAlltxn = await Contract.withdrawAll();
    withdrawAlltxn.wait();
    const balance0fContract2 = await Contract.provider.getBalance(
      Contract.address
    );
    expect(balance0fContract2).to.equal(0);
  });
});

describe("get correct token uris", function () {
  it("should return the correspondent uri to each token", async () => {
    const UkranieCharity = await hre.ethers.getContractFactory(
      "UkranieCharity"
    );
    const Contract = await UkranieCharity.deploy(
      "IStandWithUkranie",
      "ISWK",
      "https://sampleuri/",
      "0x7ec7af8cff090c533dc23132286f33dd31d13e29"
    );

    const donation = await Contract.donate({
      value: ethers.utils.parseEther("0.02"),
    });
    donation.wait();

    const tokenUrl = await Contract.uri(1);
    expect(tokenUrl).to.equal("https://sampleuri/1.json");
  });
});
