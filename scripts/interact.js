const { formatEther } = require('ethers/lib/utils')
const { ethers } = require('hardhat')
require('dotenv').config()

async function main() {

    [owner] = await ethers.getSigners()

    //get contract factory
    this.musicHead = await ethers.getContractFactory('MusicHead')
    //attach to deployed contract
    this.musicHead = this.musicHead.attach(process.env.MUSICHEAD)

    //check mintFee()
    console.log(`Mint Fee: ${formatEther(await this.musicHead.mintFee())}`)
    const mintFee = await this.musicHead.mintFee()

    //activate
    const txa = await this.musicHead.ActivateSale()
    await txa.wait()

    console.log(await this.musicHead.saleIsActive())

    //mint NFTs
    const txp = await this.musicHead.publicMint(2, { value: mintFee * 2 })
    await txp.wait()
    console.log(await this.musicHead.mintedAmount(owner.address))


}

main().catch(
    (error) => {
        console.error(error)
        process.exitCode = 1
    }
)