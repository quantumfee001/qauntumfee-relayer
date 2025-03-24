const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Check balance
  const balance = await deployer.getBalance();
  console.log("Account balance:", hre.ethers.utils.formatEther(balance), "ETH");

  const qftTokenAddress = "0xEB18Cd14C67082C856E5EC3e5faB99c66F05Ec03";
  const GasFeeManager = await hre.ethers.getContractFactory("GasFeeManager");
  console.log("Deploying GasFeeManager...");
  const gasFeeManager = await GasFeeManager.deploy(qftTokenAddress);

  console.log("Waiting for deployment transaction to be mined...");
  await gasFeeManager.deployTransaction.wait();

  console.log("GasFeeManager deployed to:", gasFeeManager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });