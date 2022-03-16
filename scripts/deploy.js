async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Token = await ethers.getContractFactory("UkraineCharity");
    const token = await Token.deploy(
        "IStandWithUkraine",
        "ISWU",
        "ipfs://QmVE3LBQ6YeHdjGmfPBbRbdfHcf6GeuLRxYHZngNyaZ4CB/",
        "0x91b2a8f20e6452C49185596Ef24c2c50359d0357"
    );
  
    console.log("Token address:", token);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });