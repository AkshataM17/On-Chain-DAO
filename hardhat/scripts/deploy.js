const {ethers} = require("hardhat");
const {CRYPTODEVS_NFT_CONTRACT_ADDRESS} = require("../constants")

async function main(){

  const fakeNFTmarketplace = await ethers.getContractFactory("FakeNFTMarketplace");
  const NFTMarketplacedeployed = await fakeNFTmarketplace.deploy()
  await NFTMarketplacedeployed.deployed();
  console.log(`Your NFT marketplace contract address is ${NFTMarketplacedeployed.address}`);

  const cryptoDevsDAO = await ethers.getContractFactory("CryptoDevsDAO");
  const cryptoDevsDAODeployed = await cryptoDevsDAO.deploy(
    NFTMarketplacedeployed.address,
    CRYPTODEVS_NFT_CONTRACT_ADDRESS, {
      value: ethers.utils.parseEther("0.5"),
    }
  );
  await cryptoDevsDAODeployed.deployed();
  console.log(`Your cryptoDevs contract is deployed to address ${cryptoDevsDAODeployed.address}`)
}

main()
.then(() => process.exit(0))
.catch((err) => console.error(err));

//Your NFT marketplace contract address is 0x0a8d4837a692A8A50891d9ec43E7243E3A68BE3A
//Your cryptoDevs contract is deployed to address 0x62facB6c2f180f63F1ae84B2B7814687Ffea7204