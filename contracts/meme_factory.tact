import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages";
import "./meme_coin";

contract MemeFactory with Deployable, OwnableTransferable, Resumable {
    owner: Address;
    stopped: Bool;
    numCoins: Int as uint256 = 0;
    const MinTonForStorage: Int = ton("0.01");
    init(){
        self.owner = sender();
        self.stopped = false;
    }

    receive(msg: NewMemeCoin){
        let ctx: Context = context();
        require(ctx.value >= ton("1"), "Not enough funds");
        self.numCoins += 1;
        let init: StateInit = initOf MemeCoin(myAddress(), self.numCoins);
        let leftValue: Int = (ctx.value - ton("1"));
        send(SendParameters{
                to: contractAddress(init),
                body: InitialMint{
                    name: msg.name,
                    description: msg.description,
                    symbol: msg.symbol,
                    decimals: msg.decimals,
                    amount: msg.amount
                }.toCell(),
                value: ton("0.5"),
                mode: SendIgnoreErrors,
                code: init.code,
                data: init.data
            }
        );
        let backValue: Int = 0;
        if (leftValue > 0) {
            backValue = leftValue;
        }
        send(SendParameters{
                to: ctx.sender,
                value: leftValue,
                bounce: false,
                mode: SendIgnoreErrors,
                body: NewMemeCoinResponse{seqno: self.numCoins}.toCell()
            }
        );
    }

    get fun numCoins(): Int {
        return self.numCoins;
    }

    get fun memeCoinAddress(seqno: Int): Address {
        return contractAddress(initOf MemeCoin(myAddress(), seqno));
    }
}