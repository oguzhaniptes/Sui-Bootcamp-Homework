module devhub::devcard {
  use std::option::{Self, Option};
  use std::string::{Self, String};

  use sui::transfer;
  use sui::object::{Self, UID, ID};
  use sui::tx_context::{Self, TxContext};
  use sui::url::{Self, Url};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use sui::object_table::{Self, ObjectTable};
  use sui::event;


  const NOT_THE_OWNER: u64 = 0;
  const INSUFFICENT_FUNDS: u64 = 1;
  const MIN_CARD_COST: u64 = 2;

  struct DevCard has key, store{
    id: UID,
    name: String,
    owner: address,
    title: String,
    img_url: Url,
    description: Option<String>,
    years_of_experience: u8,
    technologies: String,
    portfolio: String,
    contact: String,
    open_to_work: bool,
  }

  struct DevHub has key {
    id: UID,
    owner: address,
    counter: u64,
    cards: ObjectTable<u64, DevCard>,
  }

  struct CardCreated has copy, drop {
    id: ID,
    name: String,
    owner: address,
    title: String,
    contact: String,
  }

  struct DescriptionUpdated has copy, drop{
    name: String,
    owner: address,
    new_description: String,
  }

  fun init(ctx: &mut TxContext) {

    transfer::share_object(
      DevHub{
        id: object::new(ctx),
        owner: tx_context::sender(ctx),
        counter: 0,
        cards: object_table::new(ctx)
      }
    );
  }

  public entry fun create_card(
    name: vector<u8>,
    title: vector<u8>,
    img_url: vector<u8>,
    technologies: vector<u8>,
    portfolio: vector<u8>,
    contact: vector<u8>,
    years_of_experience: u8,
    payment: Coin<SUI>,
    devhub: &mut DevHub,
    ctx: &mut TxContext,
  ){
    let value = coin::value(&payment);
    assert!(value == MIN_CARD_COST, INSUFFICENT_FUNDS);
    transfer::public_transfer(payment, devhub.owner);

    devhub.counter = devhub.counter + 1;

    let id = object::new(ctx);

    event::emit(
      CardCreated{
        id: object::uid_to_inner(&id),
        name: string::utf8(name),
        owner: tx_context::sender(ctx),
        title: string::utf8(title),
        contact: string::utf8(contact),
      }
    );

    let devcard = DevCard{
      id: id,
      name: string::utf8(name),
      owner: tx_context::sender(ctx),
      title: string::utf8(title),
      img_url: url::new_unsafe_from_bytes(img_url),
      description: option::none(),
      years_of_experience,
      technologies: string::utf8(technologies),
      portfolio: string::utf8(portfolio),
      contact: string::utf8(contact),
      open_to_work: true,
    };

    object_table::add(&mut devhub.cards, devhub.counter, devcard);

  }

  
}