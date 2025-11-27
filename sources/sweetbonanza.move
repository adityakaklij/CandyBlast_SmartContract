/*
    1. Mint NFT
    2. Get NFT details
    3. User Points.    
    4. Get Points, user will provide 1000 points for 0.1 OCT tokens
    5. 
*/

module sweetbonanza::sweetbonanza;

use std::string::String;
use one::table;
use one::object::{Self, UID, ID};
use one::oct::{OCT};
use one::coin::{Self, Coin};
use one::tx_context::TxContext;
use one::transfer;


const OCTAMOUNT:u64 = 1_00_000_000;// 0.1 OCT

public struct PlayerNFT has key, store{
    id:UID,
    url:String,
    owner:address,
    points:u256,
}

public struct UserPoints has key{
    id:UID,
    balance: table::Table<address, u256>
}

fun init(ctx: &mut TxContext) {

     let balance = UserPoints { 
        id: object::new(ctx), 
        balance: table::new(ctx)
        };
    transfer::share_object(balance);
}

#[allow(lint(self_transfer))]
public fun mint_nft(url:String, points:u256, ctx: &mut TxContext) {
 
    let user_land = PlayerNFT {
        id: object::new(ctx),
        url,
        owner:ctx.sender(),
        points
    };
    transfer::transfer(user_land, ctx.sender());

}

public fun get_points(self:&mut Coin<OCT>,  _balance: &mut UserPoints, ctx:&mut TxContext) {
    let sender = ctx.sender();
    let payment = coin::split(self, OCTAMOUNT as u64, ctx);
    transfer::public_transfer(payment, @0x1c907d948e6c62d699735b5b655792429fb57680e3082b007c79010cd692f385);
    
    if (table::contains(&_balance.balance, sender)) {

        let oldPoints = table::borrow_mut(&mut _balance.balance, sender);
        *oldPoints = *oldPoints + 1000;

        
    } else {
        table::add(&mut _balance.balance, sender, 1000);
    };
}