import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MemeFactory } from '../wrappers/MemeFactory';
import '@ton/test-utils';

describe('MemeFactory', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let memeFactory: SandboxContract<MemeFactory>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        memeFactory = blockchain.openContract(await MemeFactory.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await memeFactory.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: memeFactory.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and memeFactory are ready to use
    });
});
