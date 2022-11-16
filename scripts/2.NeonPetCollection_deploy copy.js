
const { ethers } = require("hardhat");
const { utils} = require("ethers");

async function main() {

  [owner, user1, user2, user3, user4] =await ethers.getSigners()
  console.log(`           Owner address:${owner.address}`)

this.VAS = await ethers.getContractFactory("VasReward")
this.VAS = await this.VAS.deploy("VAS Reward Token","VAS", utils.parseEther('1000000000'))
await this.VAS.deployed()
console.log(`           VAS Reward Token Deploed at: ${this.VAS.address}`)


this.CollectionMinter = await ethers.getContractFactory("CollectionMinter")
this.CollectionMinter = await this.CollectionMinter.deploy()
await this.CollectionMinter.deployed()
console.log(`           CollectionMinter Deployed at:${this.CollectionMinter.address}`)

await this.CollectionMinter.createNewCollection("CryptoOwl Collection", "COC", "HTTPS://Empire/collections/COC/",owner.address) 
const CryptoOwlAddress = await this.CollectionMinter.collectionAddress()
console.log(`           CryptoOwl Collection deployed at:${CryptoOwlAddress}`)

//1.using getContractAt
//this.COC = await ethers.getContractAt("LaunchpadCollection",CryptoOwlAddress)
//2. using attach
this.COC = await ethers.getContractFactory("LaunchpadCollection"); 
this.COC = this.COC.attach(CryptoOwlAddress)


  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
