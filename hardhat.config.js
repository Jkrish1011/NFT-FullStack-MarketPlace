require("@nomiclabs/hardhat-waffle");
const projectId = "70b584d0d70848a4bd44992a1a147724"
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()

module.exports = {
  networks:{
    hardhat: {
      chainId: 1337
    },
    mumbai:{
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    }
  },
  solidity: "0.8.4",
};
