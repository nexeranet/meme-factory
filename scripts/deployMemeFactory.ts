import { toNano } from '@ton/core';
import { MemeFactory } from '../wrappers/MemeFactory';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const memeFactory = provider.open(await MemeFactory.fromInit());

    await memeFactory.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(memeFactory.address);

    // run methods on `memeFactory`
}
