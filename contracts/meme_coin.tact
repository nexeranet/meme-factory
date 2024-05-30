import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";
import "./meme_wallet";

contract MemeCoin with Deployable, Ownable {
    owner: Address;
    mintable: Bool;
    totalSupply: Int as coins = 0;
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

    receive(msg: BuyCoins) {
        require(context().value >= self.getPrice(msg.amount), "Not enough funds");
        // Create message
        let winit: StateInit = self.getMemeWalletInit(sender());
        let walletAddres: Address = contractAddress(winit);
        self.balance = self.balance - msg.amount;
        send(SendParameters{
                to: walletAddress,
                value: 0,
                bounce: false,
                mode: SendRemainingValue,
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
    }

    receive(msg: SellCoins) {
        let price: Int = self.getPrice(msg.amount);
        require(myBalance() >= price, "Not enough funds");
        self.balance = self.balance + msg.amount;
        // Create message
        let destination: StateInit = self.getMemeWalletInit(sender());
        let destinationAddress: Address = contractAddress(destination);
        let responseDestination: StateInit = self.getMemeWalletInit(myAddress());
        let responseDestinationAddress: Address = contractAddress(responseDestination);
        send(SendParameters{
                to: destinationAddress,
                value: price,
                bounce: false,
                mode: SendRemainingValue,
                body: TokenTransfer{
                    queryId: 0,
                    amount: msg.amount,
                    destination: destinationAddress,
                    responseDestination: responseDestinationAddress,
                    forwardTonAmount: 0,
                    customPayload: beginCell().endCell(),
                    forwardPayload: emptySlice()
                }.toCell(),
                code: destination.code,
                data: destination.data
            }
        );
    }
    // https://github.com/ton-blockchain/TEPs/blob/master/text/0089-jetton-wallet-discovery.md
    receive(msg: ProvideWalletAddress) { // 0x2c76b973
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
            });
        } else {
            send(SendParameters{
                to: sender(),
                value: 0,
                mode: SendRemainingValue,
                body: TakeWalletAddress { // 0xd1735400
                    query_id: msg.query_id,
                    wallet_address: contractAddress(init),
                    owner_address: beginCell().storeBool(false).endCell().asSlice()
                }.toCell()
            });
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

    get fun get_price(amount: Int): Int{
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
        self.totalSupply = self.totalSupply + amount;
        self.mintable = false;
        self.balance = self.totalSupply + amount;
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