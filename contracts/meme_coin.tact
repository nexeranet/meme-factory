import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";
import "./meme_wallet";
import "./constants";

contract MemeCoin with Deployable, Ownable {
    owner: Address;
    mintable: Bool;
    totalSupply: Int as coins = 0;
    reserved: Int as coins = 0;
    balance: Int as coins = 0;
    seqno: Int as uint256;
    content: Cell?;
    init(owner: Address, seqno: Int){
        self.owner = owner;
        self.seqno = seqno;
        self.mintable = true;
    }

    receive(msg: InitialMint){
        self.requireOwner();
        self.content = JettonContent{name: msg.name, description: msg.description, symbol: msg.symbol}.toCell();
        self.mint(myAddress(), msg.amount, myAddress());
    }

    receive(msg: TokenUpdateContent){
        // Allow changing content only by owner
        self.requireOwner();
        // Update content
        self.content = msg.content;
    }

    receive(msg: TokenBurnNotification){
        // Check wallet
        self.requireWallet(msg.owner);
        // Update supply
        self.totalSupply = (self.totalSupply - msg.amount);
        // Cashback
        if (msg.responseAddress != null) {
            send(SendParameters{
                    to: msg.responseAddress!!,
                    value: 0,
                    bounce: false,
                    mode: (SendRemainingValue + SendIgnoreErrors),
                    body: TokenExcesses{queryId: msg.queryId}.toCell()
                }
            );
        }
    }

    receive(msg: BuyCoins){
        let ctx: Context = context();
        let price: Int = self.getPrice(msg.amount);
        require(ctx.value >= (price + ton("0.1")), "Not enough funds");
        // Create message
        let winit: StateInit = self.getMemeWalletInit(sender());
        let walletAddress: Address = contractAddress(winit);
        self.balance = (self.balance - msg.amount);
        let leftFunds: Int = ((ctx.value - price) - ton("0.1"));
        send(SendParameters{
                to: walletAddress,
                value: ton("0.1"),
                bounce: false,
                mode: SendIgnoreErrors,
                body: TokenTransferInternal{
                    amount: msg.amount,
                    queryId: 0,
                    from: myAddress(),
                    responseAddress: sender(),
                    forwardTonAmount: 0,
                    forwardPayload: emptySlice()
                }.toCell(),
                code: winit.code,
                data: winit.data
            }
        );
        if (leftFunds > 0) {
            send(SendParameters{
                    to: ctx.sender,
                    value: leftFunds,
                    bounce: false,
                    mode: SendIgnoreErrors,
                    body: "Left funds".asComment()
                }
            );
        }
    }

    receive(msg: SellCoins){
        let price: Int = self.getPrice(msg.amount);
        let ctx: Context = context();
        require((myBalance() - MIN_TONS_FOR_STORAGE) >= price, "Not enough funds");
        self.balance = (self.balance + msg.amount);
        // Create message
        let destination: StateInit = self.getMemeWalletInit(ctx.sender);
        let destinationAddress: Address = contractAddress(destination);
        let leftFunds: Int = ctx.value - ton("0.1");

        send(SendParameters{
                to: destinationAddress,
                value: ton("0.1"),
                bounce: true,
                mode: SendPayGasSeparately | SendIgnoreErrors,
                body: TokenWithdraw{queryId: 0, from: ctx.sender, amount: msg.amount}.toCell()
            }
        );
        if (leftFunds > 0) {
            send(SendParameters{
                    to: ctx.sender,
                    value: leftFunds,
                    bounce: false,
                    mode: SendIgnoreErrors,
                    body: "Left funds".asComment()
                }
            );
        }
    }

    // https://github.com/ton-blockchain/TEPs/blob/master/text/0089-jetton-wallet-discovery.md
    receive(msg: ProvideWalletAddress){
        // 0x2c76b973
        require(context().value >= ton("0.0061"), "Insufficient gas");
        let init: StateInit = initOf MemeWallet(msg.owner_address, myAddress());
        if (msg.include_address) {
            send(SendParameters{
                    to: sender(),
                    value: 0,
                    mode: SendRemainingValue,
                    body: TakeWalletAddress{
                        query_id: msg.query_id,
                        wallet_address: contractAddress(init),
                        owner_address: beginCell().storeBool(true).storeAddress(msg.owner_address).endCell().asSlice()
                    }.toCell()
                }
            );
        } else {
            send(SendParameters{
                    to: sender(),
                    value: 0,
                    mode: SendRemainingValue,
                    body: TakeWalletAddress{ // 0xd1735400
                        query_id: msg.query_id,
                        wallet_address: contractAddress(init),
                        owner_address: beginCell().storeBool(false).endCell().asSlice()
                    }.toCell()
                }
            );
        }
    }

    // Get Methods
    //

    get fun balance(): Int {
        return self.balance;
    }

    get fun get_wallet_address(owner: Address): Address {
        let winit: StateInit = self.getMemeWalletInit(owner);
        return contractAddress(winit);
    }

    get fun get_jetton_data(): JettonData {
        let code: Cell = self.getMemeWalletInit(myAddress()).code;
        return
            JettonData{
                totalSupply: self.totalSupply,
                mintable: self.mintable,
                owner: self.owner,
                content: self.content,
                walletCode: code
            };
    }

    get fun get_price(amount: Int): Int {
        return self.getPrice(amount);
    }

    //
    // Private Methods
    //

    fun getPrice(amount: Int): Int {
        return amount * 1;
    }

    fun mint(to: Address, amount: Int, responseAddress: Address) {
        // Update total supply
        self.totalSupply = amount;
        self.mintable = false;
        self.balance = amount;
        self.reply("Minted".asComment());
    }

    fun requireWallet(owner: Address) {
        let ctx: Context = context();
        let winit: StateInit = self.getMemeWalletInit(owner);
        require(contractAddress(winit) == ctx.sender, "Invalid sender");
    }

    fun getMemeWalletInit(address: Address): StateInit {
        return initOf MemeWallet(myAddress(), address);
    }
}