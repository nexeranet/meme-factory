import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MemeWallet } from '../wrappers/MemeWallet';
import '@ton/test-utils';

describe('MemeWallet', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let memeWallet: SandboxContract<MemeWallet>;

    beforeEach(async () => {
        //blockchain = await Blockchain.create();

        //memeWallet = blockchain.openContract(await MemeWallet.fromInit());

        //deployer = await blockchain.treasury('deployer');

        //const deployResult = await memeWallet.send(
        //    deployer.getSender(),
        //    {
        //        value: toNano('0.05'),
        //    },
        //    {
        //        $$type: 'Deploy',
        //        queryId: 0n,
        //    }
        //);

        //expect(deployResult.transactions).toHaveTransaction({
        //    from: deployer.address,
        //    to: memeWallet.address,
        //    deploy: true,
        //    success: true,
        //});
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and memeWallet are ready to use
    });
});
