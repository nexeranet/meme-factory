import { toNano } from '@ton/core';
import { MemeWallet } from '../wrappers/MemeWallet';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const memeWallet = provider.open(await MemeWallet.fromInit());

    await memeWallet.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(memeWallet.address);

    // run methods on `memeWallet`
}
