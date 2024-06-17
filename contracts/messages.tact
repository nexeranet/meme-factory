message(0xf8a7ea5) TokenTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    responseDestination: Address?;
    customPayload: Cell?;
    forwardTonAmount: Int as coins;
    forwardPayload: Slice as remaining;
}

message(0x178d4519) TokenTransferInternal {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    responseAddress: Address?;
    forwardTonAmount: Int as coins;
    forwardPayload: Slice as remaining;
}

message(0x7362d09c) TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forwardPayload: Slice as remaining;
}

message(0x595f07bc) TokenBurn {
    queryId: Int as uint64;
    amount: Int as coins;
    owner: Address;
    responseAddress: Address?;
}

message(0x7bdd97de) TokenBurnNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    owner: Address;
    responseAddress: Address?;
}

message(0xd53276db) TokenExcesses {
    queryId: Int as uint64;
}

message(0x00030D40) TokenUpdateContent {
    content: Cell?;
}

// ==== TEP89: Jetton Wallet Discovery ====
message(0x2c76b973) ProvideWalletAddress {
    query_id: Int as uint64;
    owner_address: Address;
    include_address: Bool;
}

// take_wallet_address#d1735400 
// query_id:uint64 wallet_address:MsgAddress owner_address:(Maybe ^MsgAddress) = InternalMsgBody;
message(0xd1735400) TakeWalletAddress {
    query_id: Int as uint64;
    wallet_address: Address;
    owner_address: Slice as remaining;
}
message(0x000493e0) TokenWithdraw {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
}

message(0x00061a80) InitialMint {
    name: String;
    description: String;
    symbol: String;
    decimals: String;
    amount: Int as uint256;
    creator: Address;
}

message(0x0007a120) NewMemeCoin {
    name: String;
    description: String;
    symbol: String;
    decimals: String;
    amount: Int as uint256;
}

message(0x000927c0) BuyCoins {
    amount: Int as uint256;
}

message(0x000a00c3) SellCoins {
    amount: Int as uint256;
}

struct JettonData {
    totalSupply: Int;
    mintable: Bool;
    owner: Address;
    content: Cell?;
    walletCode: Cell;
}

struct JettonWalletData {
    balance: Int;
    owner: Address;
    master: Address;
    walletCode: Cell;
}

struct JettonContent {
    name : String;
    description: String;
    symbol: String;
}
struct NewMemeCoinResponse{  
    seqno: Int as uint256;
}
