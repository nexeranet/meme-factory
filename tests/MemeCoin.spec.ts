import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MemeCoin } from '../wrappers/MemeCoin';
import '@ton/test-utils';

describe('MemeCoin', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let memeCoin: SandboxContract<MemeCoin>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        memeCoin = blockchain.openContract(await MemeCoin.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await memeCoin.send(
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
            to: memeCoin.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and memeCoin are ready to use
    });
});
