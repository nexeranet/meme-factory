import { getHttpEndpoint } from "@orbs-network/ton-access";
import { TonClient, Address, fromNano, toNano } from "@ton/ton";
import { MemeFactory } from "../wrappers/MemeFactory"; // this is the interface class we just implemented
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    // initialize ton rpc client on testnet
    const endpoint = await getHttpEndpoint({ network: "testnet" });
    const client = new TonClient({ endpoint });

    // open Counter instance by address
    const contractAddress = Address.parse("EQASh5RHX-cEvEYKSDb0I6At4p8Kv7U3FCUl_mD5I_5HjjpL"); // replace with your address from step 8
    const factory = MemeFactory.fromAddress(contractAddress);
    const factoryContract = client.open(factory);

    // call the getter on chain
    const counterValue = await factoryContract.getNumCoins();

    let result = await factoryContract.send(
        provider.sender(),
        {
            value: toNano('1.2'),
            bounce: false
        },
        {
            $$type: 'NewMemeCoin',
            name: "Test2",
            description: "Test coin2",
            symbol: "TEST2",
            decimals: "9",
            amount: 1000n
        }
    );
    console.log(result);
}
