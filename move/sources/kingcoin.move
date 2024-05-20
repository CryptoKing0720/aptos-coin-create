module kingcoin::token {
    use std::signer;
    use std::string::{Self, String};
    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability, FreezeCapability};

    const E_NOT_INITIALIZED: u64 = 0;
    const E_MINT_CAPABILITY_NOT_DERIVED: u64 = 1;

    struct TokenInfo has key {
        name: String,
        symbol: String,
        decimals: u8,
        supply: u64,
    }

    struct MintCapability has key {}

    public fun init_module(account: &signer, name: vector<u8>, symbol: vector<u8>, decimals: u8, initial_supply: u64) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<TokenInfo>(
            account,
            string::utf8(name),
            string::utf8(symbol),
            decimals,
            initial_supply,
            true,
        );
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_freeze_cap(freeze_cap);
        move_to(account, MintCapability {});
        move_to(account, mint_cap);
    }

    public fun mint(account: &signer, amount: u64): Coin<TokenInfo> acquires MintCapability {
        assert!(exists<MintCapability>(@my_token), E_NOT_INITIALIZED);
        let mint_cap = borrow_global<MintCapability<TokenInfo>>(@my_token);
        coin::mint(mint_cap, amount)
    }

    #[test(account = @0x123)]
    public fun test_mint(account: &signer) acquires MintCapability {
        init_module(account, b"My Token", b"MTK", 8, 1000000000);
        let token = mint(account, 100);
        assert!(coin::value(&token) == 100, 0);
    }
}