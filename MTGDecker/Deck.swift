//
//  Deck.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/23/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation


class DeckOrig{
    
    var cards: [Card];
    lazy var decksize: Int = self.cards.count;
    
    /**
        Initializer. Allows for copying another array of cards into the Deck object.
     */
    init(cards: [Card] = []){
        
        self.cards = cards;
        
    }//init
    
    
    /**
    shuffles the deck
    */
    func shuffle(){
        
        for i in stride(from: (decksize - 1), through: 0, by: -1){
            let newIndex: Int = Int(arc4random_uniform(UInt32(i)));
            
            self.swap(i: i, j: newIndex);
        }//for i (descending)
        
    }//shuffle
    
    /**
     Exchanges cards between two indexes
    */
    private func swap (i: Int, j: Int){
        let temp: Card = cards[i];
        cards[i] = cards[j];
        cards[j] = temp;
        return;
    }//swap
    
    /**
     Sorts based on parameters from the Card class
    */
    func sort(){
        self.cards.sort(by: {$0 < $1});
    }//sort
    
    
    /**
     Deals a hand off the top of the deck. Defaults to 7-card size.
    */
    func hand(size: Int = 7) -> [Card]?{
        
        if (size < 0){
            NSLog("Error: hand size cannot be less than 0.");
            return nil;
        }//if hand size too small
        if (size > decksize){
            NSLog("Error: hand size cannot exceed size of deck.");
            return nil;
        }//if hand size too big
        
        var result: [Card] = [];
        
        for i in 0...(size - 1){
            result.append(cards[i]);
        }//for
        
        return result;
    }//hand
    
    /**
     Deals a hand off the top of the deck, with 7 cards. Then applies Mulligan rules, as defined in shouldMulligan();
    */
    func handWithMulligans() -> [Card]?{
        var size: Int = 7;
        
        var resultHand: [Card] = hand(size: size)!;
        
        while (self.shouldMulligan(hand: resultHand)){
            self.shuffle();
            size -= 1;
            resultHand = hand(size: size)!;
        }//while mulligans
        
        return resultHand;
        
    }//handWithMulligans
    
    /**
     Adds a card into the deck
     */
    func addCard(card: Card){
        self.cards.append(card);
    }//addCard
    
    /**
     A stand-in for mulligan rules. Defaults to land-based mulligans
     */
    func shouldMulligan(hand: [Card]) -> Bool{
        
        let numLands = hand.filter{$0.land}.count
        
        switch (hand.count){
        case 7:
            if (numLands == 0 || numLands == 1 || numLands == 6 || numLands == 7){
                return true
            }
            break;
        case 6:
            if (numLands == 0 || numLands == 1 || numLands == 5 || numLands == 6){
                return true
            }
            break;
        case 5:
            if (numLands == 0 || numLands == 5){
                return true
            }
            break;
        default:
            return false;
        }//switch

        return false;
        
    }//shouldMulligan
    
}//Deck
