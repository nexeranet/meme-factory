import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages";
import "./meme_coin";

contract MemeFactory with Deployable, OwnableTransferable, Resumable {
    owner: Address;
    stopped: Bool;
    numCoins: Int as uint256 = 0;
    init(){
        self.owner = sender();
        self.stopped = false;
    }

    receive(msg: NewMemeCoin){
        self.numCoins += 1;
        let init: StateInit = initOf MemeCoin(myAddress(), self.numCoins);
        send(SendParameters{
                to: contractAddress(init),
                body: InitialMint{
                    name: msg.name,
                    description: msg.description,
                    symbol: msg.symbol,
                    decimals: msg.decimals,
                    amount: msg.amount,
                }.toCell(),
                value: ton("0.2"),
                mode: SendIgnoreErrors,
                code: init.code,
                data: init.data
            }
        );
        self.reply(self.numCoins.toString().asComment());
        //self.reply(NewMemeCoinResponse{seqno: self.numCoins}.toCell().asComments());
    }

    get fun numCoins(): Int {
        return self.numCoins;
    }

    get fun memeCoinAddress(seqno: Int): Address {
        return contractAddress(initOf MemeCoin(myAddress(), seqno));
    }
}