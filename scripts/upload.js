const Moralis = require("moralis").default;
const fs = require("fs");

async function uploadToIpfs() {

    await Moralis.start({
        apiKey: 's8drgI3qStj4wgyrsdKehgLbBTCfyeV73kZcfLevNVJ9PwjzNci22eJZ5S0sBfB2',
    });

    let uploadArray = []

    for (i = 1; i <= 100; i++) {

        let element = {
            path: `${i}.json`,
            content: fs.readFileSync(`./metadata/json/ ${i}.json`, { encoding: 'base64' })
        }

        uploadArray.push(element)
    }

    //console.log(uploadArray)

    const response = await Moralis.EvmApi.ipfs.uploadFolder({
        abi: uploadArray,
    });

    console.log(response.result)
}

uploadToIpfs();