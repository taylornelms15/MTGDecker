//
//  FieldState.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/11/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

internal class FieldState: CustomStringConvertible{
    
    ///The raw list of cards we're using as our deck. By default, initial hand, library, and graveyard are pulled from this
    var cardDeck: [MCard]
    var hand: [MCard] = []
    var library: [MCard] = []
    var graveyard: [MCard] = []
    var battlefield: [FieldCard] = []
    var manaPool: ManaPool = ManaPool()
    
    var turnNumber: Int = 1
    var hasPlayedLand: Bool = false
    
    internal init(deck: [MCard], handSize: Int){
        self.cardDeck = Array<MCard>(deck)//creates a copy of the given deck, to avoid complications
        
        for i in 0 ..< handSize{
            self.hand.insert(cardDeck[i], at: i)
        }//makes separate array for the hand
        for j in handSize ..< cardDeck.count{
            self.library.insert(cardDeck[j], at: j - handSize)
        }//makes separate array for the library
        
    }//init
    
    internal init(state: FieldState){
        self.cardDeck = Array<MCard>(state.cardDeck)
        self.hand = Array<MCard>(state.hand)
        self.library = Array<MCard>(state.library)
        self.battlefield = Array<FieldCard>(state.battlefield)
        self.manaPool = ManaPool(pool: state.manaPool)
        
        self.turnNumber = state.turnNumber
        self.hasPlayedLand = state.hasPlayedLand
    }//init (copy)
    
    public func playCard(name: String) throws -> [FieldState]{
        if !self.hand.contains(where: { (card) -> Bool in
            card.name == name
        }){
            throw FieldStateError.notInHand(message: "Specified card (\(name) not in hand")
        }//if
        
        let myCard: MCard = self.hand.first { (card) -> Bool in
            card.name == name
        }!
        
        return try self.playCard(card: myCard)
        
    }//playCard name
    
    
    /**
     Tries to play a card. Throws an error if it can't, for whatever reason.
     - returns: An array of possible states where the card has been played
     */
    public func playCard(card: MCard) throws -> [FieldState]{
        if self.hand.contains(card) == false { throw FieldStateError.notInHand(message: "Specified card (\(card.name)) not in hand")}
        let cardIndex: Int = self.hand.index(of: card)!
        
        let possiblePool: ManaPool? = hand[cardIndex].canPayCostFrom(pools: possibleManaPools())
        if (possiblePool == nil){
            throw FieldStateError.cannotPayCost(message: "Cannot pay cost for \(card.name) out of current battlefield state")
        }//if there's no way of paying the cost
        
        if card is MCardLand{
            if self.hasPlayedLand{ throw FieldStateError.noTwoLands(message: "Cannot play \(card.name); may only play one land per turn") }//if we've already played a land this turn
            
            let newState: FieldState = FieldState(state: self)
            
            let playedCard: FieldCard = FieldCard(card: newState.hand.remove(at: cardIndex), isTapped: (card as! MCardLand).comesInTapped)
            newState.battlefield.append(playedCard)
            newState.hasPlayedLand = true
            
            return [newState]
        }//easy version for playing lands. TODO: OVERRIDE ONCE LANDS WITH COSTS HAPPEN
        
        //For non-land plays
        if card.canPayCostFrom(pool: self.manaPool){
            
        }
        
        
        return []
    }//playCard
    
    public func tapLandAtIndex(index: Int) throws -> [FieldState]{
        if self.battlefield.count == 0 || index < 0 || index >= battlefield.count{ throw FieldStateError.indexOOB(message: "Index \(index) out of bounds") }
        if (self.battlefield[index].card is MCardLand) == false{ throw FieldStateError.indexOOB(message: "Card at index \(index) is not a land card") }
        if (self.battlefield[index].isTapped){ throw FieldStateError.cannotPayCost(message: "Land at index \(index) is already tapped") }
        
        let landCard: MCardLand = self.battlefield[index].card as! MCardLand
        
        var resultStates: [FieldState] = []
        
        for possibleYield: ManaPool in landCard.possibleYields(){
            let newState: FieldState = FieldState(state: self)//make copy of current state
            
            newState.battlefield[index].isTapped = true //tap the land
            newState.manaPool = newState.manaPool + possibleYield //add that particular yield to the mana pool
            
            resultStates.append(newState)
            
        }//for each possible mana pool yield
      
        return resultStates
    }//tapLandAtIndex
    
    public func possibleManaPools()->[ManaPool]{
        let currentManaPool = self.manaPool
        let untappedLands: [FieldCard] = battlefield.filter { (fieldCard) -> Bool in
            fieldCard.card.isLand() && !fieldCard.isTapped
        }
        var landCards: [MCardLand] = []
        for land in untappedLands{
            landCards.append(land.card as! MCardLand)
        }
        
        var result: [ManaPool] = []
        result.append(currentManaPool)
        
        for land in landCards{
            for pool in result{
                for possibleYield in land.possibleYields(){
                    let altPool = pool + possibleYield
                    result.append(altPool)
                }//for each possible yield per land card
            }//for each currently possible pool
        }//for each land card

        result = Array<ManaPool>(Set<ManaPool>(result))//remove duplicates
        
        return result
    }//possibleManaPools
    
    public var description: String{
        var handString = "Hand: {"
        for card in self.hand{
            handString.append("[\(card.name)] ")
        }
        handString.append("}")
        var battlefieldString = "Battlefield: {"
        for card in self.battlefield{
            battlefieldString.append("\(card)")
        }
        battlefieldString.append("}")
        
        return "\(handString)\n\(battlefieldString)"
    }//description
    
    internal struct FieldCard: CustomStringConvertible{
        var card: MCard
        var isTapped: Bool = false
        
        public var description: String{
            return "[\(card.name)\(isTapped ? ", tapped" : "" )]"
        }
        
    }//FieldCard
    
}//FieldState

enum FieldStateError: Error{
    case notInHand(message: String)
    case cannotPayCost(message: String)
    case noTwoLands(message: String)
    case indexOOB(message: String)
}//SimulatorError
