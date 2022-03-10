const { ethers } = require("ethers");
const hre = require("hardhat");

async function main() {
  const [owner, addr1, addr2] = await hre.ethers.getSigners();

  const UkranieCharity = await hre.ethers.getContractFactory("UkranieCharity");

  // name / symbol / uri / multisig
  const instance = await UkranieCharity.deploy(
    "IStandWithUkranie",
    "ISWK",
    "https://sampleuri",
    "0x7ec7af8cff090c533dc23132286f33dd31d13e29"
  );

  const txn = await instance.donate({
    value: ethers.utils.parseEther("0.06"),
  });

  await txn.wait();

  const txn2 = await instance.connect(addr1).donate({
    value: ethers.utils.parseEther("1"),
  });

  await txn2.wait();

  const totalraised = await instance.totalraised();

  const donationEvent = instance.filters.donated(null, null);
  const balanceOfAdd2 = await instance.balanceOf(addr1.address, 2);
  console.log("balance of ", balanceOfAdd2);
  console.log(donationEvent);

  const withdrawTxn = await instance.withdrawAll();
  await withdrawTxn.wait();
  const balance0ETH = await instance.provider.getBalance(instance.address);
  console.log("contract balance ", balance0ETH);
  console.log("contract deployed to", instance.address);
  console.log("total raised is ", totalraised);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
