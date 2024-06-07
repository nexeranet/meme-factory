import "@stdlib/deploy";
import "./messages";
import "./constants";

contract MemeWallet with Deployable {
    master: Address;
    owner: Address;
    balance: Int as coins;
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");
    init(master: Address, owner: Address){
        self.balance = 0;
        self.owner = owner;
        self.master = master;
    }

    receive(msg: TokenTransfer){
        // Check sender
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        // Update balance
        let newBalance: Int = (self.balance - msg.amount);
        require(newBalance >= 0, "Invalid balance");
        self.balance = newBalance;
        // Gas checks
        let fwdFee: Int = ctx.readForwardFee();
        let fwdCount: Int = 1;
        if (msg.forwardTonAmount > 0) {
            fwdCount = 2;
        }
        require(ctx.value > gasCheckConsumption(fwdFee, fwdCount), "Not enough funds for gas consumption");
        // Send tokens
        let init: StateInit = initOf MemeWallet(self.master, msg.destination);
        let walletAddress: Address = contractAddress(init);
        send(SendParameters{
                to: walletAddress,
                value: 0,
                mode: SendRemainingValue,
                bounce: true,
                body: TokenTransferInternal{
                    amount: msg.amount,
                    queryId: msg.queryId,
                    from: self.owner,
                    responseAddress: self.owner,
                    forwardTonAmount: msg.forwardTonAmount,
                    forwardPayload: msg.forwardPayload
                }.toCell(),
                code: init.code,
                data: init.data
            }
        );
    }

    receive(msg: TokenWithdraw){  
        // Check sender
        require(sender() == self.master, "Only master");
        require(msg.from == self.owner, "Only owner");
        // Update balance
        let newBalance: Int = (self.balance - msg.amount);
        require(newBalance >= 0, "Invalid balance");
        self.balance = newBalance;
    }

    receive(msg: TokenTransferInternal){
        // Check sender
        let ctx: Context = context();
        if (ctx.sender != self.master) {
            let sinit: StateInit = initOf MemeWallet(self.master, msg.from);
            require(contractAddress(sinit) == ctx.sender, "Invalid sender");
        }
        // Update balance
        self.balance = (self.balance + msg.amount);
        require(self.balance >= 0, "Invalid balance");
        // Adjust value for gas
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg: Int = (myBalance() - msgValue);
        let storageFee: Int = (MIN_TONS_FOR_STORAGE - min(tonBalanceBeforeMsg, MIN_TONS_FOR_STORAGE));
        msgValue = (msgValue - (storageFee + GAS_CONSUMPTION));
        // Forward ton
        if (msg.forwardTonAmount > 0) {
            let fwdFee: Int = ctx.readForwardFee();
            msgValue = (msgValue - (msg.forwardTonAmount + fwdFee));
            send(SendParameters{
                    to: self.owner,
                    value: msg.forwardTonAmount,
                    bounce: false,
                    body: TokenNotification{
                        queryId: msg.queryId,
                        amount: msg.amount,
                        from: msg.from,
                        forwardPayload: msg.forwardPayload
                    }.toCell()
                }
            );
        }
        // Cashback
        if (msg.responseAddress != null && msgValue > 0) {
            send(SendParameters{
                    to: msg.responseAddress!!,
                    value: msgValue,
                    bounce: false,
                    body: TokenExcesses{queryId: msg.queryId}.toCell()
                }
            );
        }
    }

    receive(msg: TokenBurn){
        // Check sender
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        // Update balance
        self.balance = (self.balance - msg.amount);
        require(self.balance >= 0, "Invalid balance");
        // Gas checks
        let fwdFee: Int = ctx.readForwardFee();
        require(ctx.value > ((fwdFee + 2 * self.gasConsumption) + self.minTonsForStorage), "Invalid value");
        // Burn tokens
        send(SendParameters{
                to: self.master,
                value: 0,
                mode: SendRemainingValue,
                bounce: true,
                body: TokenBurnNotification{
                    queryId: msg.queryId,
                    amount: msg.amount,
                    owner: self.owner,
                    responseAddress: self.owner
                }.toCell()
            }
        );
    }

    bounced(msg: Slice){
        // Parse bounced message
        msg.skipBits(32); // 0xFFFFFFFF
        let op: Int = msg.loadUint(32);
        let queryId: Int = msg.loadUint(64);
        let jettonAmount: Int = msg.loadCoins();
        require(op == 0x178d4519 || op == 0x7bdd97de, "Invalid bounced message");
        // Update balance
        self.balance = (self.balance + jettonAmount);
    }

    get fun get_wallet_data(): JettonWalletData {
        return
            JettonWalletData{
                balance: self.balance,
                owner: self.owner,
                master: self.master,
                walletCode: initOf MemeWallet(self.master, self.owner).code
            };
    }
}