import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Address, toNano } from '@ton/core';
import { MemeCoin, InitialMint } from '../wrappers/MemeCoin';
import { MemeWallet } from '../wrappers/MemeWallet';
import '@ton/test-utils';
import { randomAddress } from '@ton/test-utils';

describe('MemeCoin', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let memeCoin: SandboxContract<MemeCoin>;
    let ownerAddress: Address = randomAddress(0);

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');
        ownerAddress = deployer.address;
        memeCoin = blockchain.openContract(await MemeCoin.fromInit(ownerAddress, 1n));


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
    it('should deploy wallet after mint', async () => {
        // the check is done inside beforeEach
        // blockchain and memeCoin are ready to use

        const message: InitialMint = {
            $$type: 'InitialMint',
            name: "NewCoin",
            description: "New coins description",
            symbol: "NEW",
            decimals: "9",
            amount: toNano("100.0"),
        }

        await memeCoin.send(deployer.getSender(), {
            value: toNano("0.5")
        }, message)
        
        const memeWalletAddress  = await memeCoin.getGetWalletAddress(memeCoin.address)
        const memeWalletContract = await blockchain.openContract(MemeWallet.fromAddress(memeWalletAddress))
        const metadata = await memeCoin.getGetJettonData()
        expect(metadata.totalSupply).toEqual(toNano("100.0"))
        const metadataWallet = await memeWalletContract.getGetWalletData()
        expect(metadataWallet.balance).toEqual(toNano("100.0"))
    });
});
