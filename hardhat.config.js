require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.0" },  // For GasFeeManager.sol
      { version: "0.8.28" }  // For Lock.sol (if you keep it)
    ]
  },
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/-08irZtFq0AjAZVdTJyoCnLQ33YZVq-3",
      accounts: ["571eb84205cd1384ddbadb6cff6ec6f3000f8d5624dd40ffe0744e14806f55dd"]
    }
  }
};