require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({path: ".env"});

const ALCHEMY_HTTP_URL = process.env.ALCHEMY_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: ALCHEMY_HTTP_URL,
      accounts: [PRIVATE_KEY],
    }
  },
  etherscan:{
    apiKey: ETHERSCAN_API_KEY,
  },
};

//Your NFT marketplace contract address is 0x0a8d4837a692A8A50891d9ec43E7243E3A68BE3A
//Your cryptoDevs contract is deployed to address 0x62facB6c2f180f63F1ae84B2B7814687Ffea7204