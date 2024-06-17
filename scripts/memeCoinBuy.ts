import { getHttpEndpoint } from "@orbs-network/ton-access";
import { TonClient, Address, fromNano, toNano, Cell } from "@ton/ton";
import { MemeCoin, BuyCoins } from "../wrappers/MemeCoin"; // this is the interface class we just implemented
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    // initialize ton rpc client on testnet
    const endpoint = await getHttpEndpoint({ network: "testnet" });
    const client = new TonClient({ endpoint });

    // open Counter instance by address
    const contractAddress = Address.parse("kQC8AeO3reHlWGqnaYNLhv6ehBnpv1Gx5EzDIhTs1PdBo6VM"); // replace with your address from step 8
    const address = MemeCoin.fromAddress(contractAddress);
    const contract = client.open(address);

    // call the getter on chain
    const data = await contract.getGetJettonData();
    console.log("Jettons have", data.totalSupply);

    const message: BuyCoins = {
        $$type: 'BuyCoins',
        amount: 100n,
    }
    let result = await contract.send(
        provider.sender(),
        {
            value: toNano('1.0'),
            bounce: false
        },
        message
    );
    console.log(result)
    const dataLeft = await contract.getGetJettonData();
    
    console.log("Jettons left", dataLeft.totalSupply);
}