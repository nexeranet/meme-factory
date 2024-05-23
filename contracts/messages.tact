
message NewMemeCoin {
    name: String;
    description: String;
    symbol: String;
    decimals: String;
    amount: Int as uint256;
}

message InternalMint {
    amount: Int as uint256;
}

message NewMemeCoinResponse {
    seqno: Int as uint256;
}