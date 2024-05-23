import "@stdlib/deploy";
import "./messages";

contract MemeCoin with Deployable {
    parent: Address;
    seqno: Int as uint256;
    name : String  = "";
    description: String = "";
    symbol: String = "";
    totalAmount: Int as coins = 0;

    init(parent: Address, seqno: Int) {
        self.parent = parent; 
        self.seqno = seqno;
    }

    receive(msg: NewMemeCoin) {
        require(sender() == self.parent, "Parent only");
        self.name = msg.name;
        self.description = msg.description;
        self.symbol = msg.symbol;
        self.totalAmount = msg.amount;
    }
}
