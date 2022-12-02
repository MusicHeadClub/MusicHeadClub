
const { ethers } = require("hardhat");
require('dotenv').config()

async function main() {

    //get contract factory
    this.musichead = await ethers.getContractFactory('MusicHead')
    //deploy 
    this.musichead = await this.musichead.deploy(process.env.METADATA)
    //get deployed address
    console.log(`MUSICHEAD=${this.musichead.address}`)
}

main().catch(
    (error) => {
        console.error(error)
        process.exitCode = 1;
    }
)