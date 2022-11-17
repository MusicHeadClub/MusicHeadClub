const fs = require('fs')
require('dotenv')

fs.readFile('./metadata/json/_metadata.json', 'utf8', function read(error, data) {
    if (error) {
        throw error
    }

    processFile(data)
})

async function processFile(content) {

    const neonPet = JSON.parse(content)
    let limit = 0

    neonPet.forEach(element => {
        // limit++
        // if (limit <= 50) {
        //     element["description"] = `MisicHeadClud NFTs collection`
        //     element['image'] = `https://ipfs.io/ipfs/bafybeiarbmmq3neooyjrbikd6ikuuznc2u3cawzpdeosaho3jbpfny2hia/${element['edition']}.png`
        //     element["external_url"] = `https://musicheadclub.com/`
        //     fs.writeFile(`./metadata/json/ ${element['edition']}.json`, JSON.stringify(element, null, 2), (err) => {
        //         if (err) throw err
        //         console.log(`${element['edition']}.json`)
        //     })

        // }

        element["description"] = `MisicHeadClud NFTs collection`
        element['image'] = `https://ipfs.io/ipfs/bafybeiarbmmq3neooyjrbikd6ikuuznc2u3cawzpdeosaho3jbpfny2hia/${element['edition']}.png`
        element["external_url"] = `https://musicheadclub.com/`
        fs.writeFile(`./metadata/json/ ${element['edition']}.json`, JSON.stringify(element, null, 2), (err) => {
            if (err) throw err
            console.log(`${element['edition']}.json`)
        })

    });


}
