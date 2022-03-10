const expect = require("chai").expect;
const { ethers } = require("hardhat");

describe("mints", function () {
  it("Should mint the corresponding nfts to the senders", async function () {
    const [owner, addr1, addr2] = await hre.ethers.getSigners();

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

    // Tier 3 test
  });
});
