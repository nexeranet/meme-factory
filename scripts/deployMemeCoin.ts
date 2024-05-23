import { toNano } from '@ton/core';
import { MemeCoin } from '../wrappers/MemeCoin';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const memeCoin = provider.open(await MemeCoin.fromInit());

    await memeCoin.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(memeCoin.address);

    // run methods on `memeCoin`
}
