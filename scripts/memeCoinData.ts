import { getHttpEndpoint } from "@orbs-network/ton-access";
import { TonClient, Address, fromNano, toNano, Cell } from "@ton/ton";
import { MemeCoin, BuyCoins } from "../wrappers/MemeCoin"; // this is the interface class we just implemented
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    // initialize ton rpc client on testnet
    const endpoint = await getHttpEndpoint({ network: "testnet" });
    const client = new TonClient({ endpoint });

    // open Counter instance by address
    const contractAddress = Address.parse("EQC8AeO3reHlWGqnaYNLhv6ehBnpv1Gx5EzDIhTs1PdBox7G"); // replace with your address from step 8
    const address = MemeCoin.fromAddress(contractAddress);
    const contract = client.open(address);

    // call the getter on chain
    const data = await contract.getGetJettonData();
    console.log(data);
}