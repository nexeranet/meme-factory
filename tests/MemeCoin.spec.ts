import { Blockchain, SandboxContract, TreasuryContract, printTransactionFees} from '@ton/sandbox';
import { Address, toNano, fromNano } from '@ton/core';
import { MemeCoin, InitialMint } from '../wrappers/MemeCoin';
import { MemeWallet } from '../wrappers/MemeWallet';
import '@ton/test-utils';
import { randomAddress } from '@ton/test-utils';
import { BuyCoins, SellCoins } from '../wrappers/MemeFactory';

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
        
        const metadata = await memeCoin.getGetJettonData()
        expect(metadata.totalSupply).toEqual(toNano("100.0"))
        const balance = await memeCoin.getBalance()
        expect(balance).toEqual(toNano("100.0"))
    });
    it('should sell and create wallet', async () => {
        // the check is done inside beforeEach
        // blockchain and memeCoin are ready to use

        let user = await blockchain.treasury('user', {
            balance: toNano("1.0")
        });
        let initialUserBalance = await user.getBalance();
        let priceOfGas = toNano("0.5");

        const message: InitialMint = {
            $$type: 'InitialMint',
            name: "NewCoin",
            description: "New coins description",
            symbol: "NEW",
            decimals: "9",
            amount: 100n,
        }

        await memeCoin.send(deployer.getSender(), {
            value: priceOfGas,
        }, message)
        let amountPrice = await memeCoin.getGetPrice(50n)
        const buyMsg: BuyCoins =  {
            $$type: 'BuyCoins',
            amount: amountPrice,
        }
        await memeCoin.send(user.getSender(), {
            value: amountPrice + priceOfGas,
        },  buyMsg)
        const balance = await memeCoin.getBalance()
        expect(balance).toEqual(50n)
        const memeWalletAddress  = await memeCoin.getGetWalletAddress(user.address)
        const memeWalletContract = await blockchain.openContract(MemeWallet.fromAddress(memeWalletAddress))
        let metadata = await memeWalletContract.getGetWalletData()
        expect(metadata.balance).toEqual(50n)
        const sellMsg: SellCoins =  {
            $$type: 'SellCoins',
            amount: amountPrice,
        }
        let result = await memeCoin.send(user.getSender(), {
            value: priceOfGas
        },  sellMsg)

        console.log(printTransactionFees(result.transactions))
        const sellBalance = await memeCoin.getBalance()
        expect(sellBalance).toEqual(100n)
        let sellmetadata = await memeWalletContract.getGetWalletData()
        expect(sellmetadata.balance).toEqual(0n)
        let endUserBalance = await user.getBalance()
        console.log(fromNano(initialUserBalance), fromNano(endUserBalance), fromNano(initialUserBalance - endUserBalance))
        //expect(endUserBalance).toEqual(initialUserBalance - (2n * priceOfGas))
        //console.log(endUserBalance, initialUserBalance)
    });
});
