//
//  FieldState.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/11/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

internal class FieldState: CustomStringConvertible, Equatable, Hashable{
    
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
    
    static func == (lhs: FieldState, rhs: FieldState) -> Bool {
        
        if lhs.manaPool != rhs.manaPool {return false}
        if lhs.turnNumber != rhs.turnNumber {return false}
        //hand, graveyard, battlefield: not order-dependent
        if !lhs.hand.containsSameElements(as: rhs.hand){
            return false
        }
        if !lhs.graveyard.containsSameElements(as: rhs.graveyard){
            return false
        }
        if !lhs.battlefield.containsSameElements(as: rhs.battlefield){
            return false
        }

        if lhs.library != rhs.library{
            return false
        }
        
        return true
    }//operator ==
    
    //TODO: make not a terrible function
    var hashValue: Int{
        return manaPool.hashValue ^ turnNumber.hashValue ^ hasPlayedLand.hashValue
    }//hashValue
    
    /**
     Sets up for next turn (functions as the Untap and Upkeep phases). One of the few deliberately mutating methods for this class
     */
    public func advanceTurn(){
        //TODO: draw cards maybe? (later date)
        turnNumber += 1//increase turn number
        hasPlayedLand = false//allow us to play another land
        manaPool = ManaPool()//clear the mana pool
        
        for i in 0 ..< battlefield.count{
            if battlefield[i].isTapped || battlefield[i].isSick{
                let newCard: FieldCard = FieldCard(card: battlefield[i].card, isTapped: false, isSick: false)
                battlefield[i] = newCard
            }
        }//for each card on the battlefield
    }//advanceTurn
    
    
    public func playCard(name: String) throws -> Set<FieldState>{
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
    public func playCard(card: MCard) throws -> Set<FieldState>{
        if self.hand.contains(card) == false { throw FieldStateError.notInHand(message: "Specified card (\(card.name)) not in hand")}
        let cardIndex: Int = self.hand.index(of: card)!
        
        let possiblePool: ManaPool? = hand[cardIndex].canPayCostFrom(pools: possibleManaPools())
        if (possiblePool == nil){
            throw FieldStateError.cannotPayCost(message: "Cannot pay cost for \(card.name) out of current battlefield state")
        }//if there's no way of paying the cost
        
        if card is MCardLand{
            if self.hasPlayedLand{ throw FieldStateError.noTwoLands(message: "Cannot play \(card.name); may only play one land per turn") }//if we've already played a land this turn
            
            let newState: FieldState = FieldState(state: self)
            
            let playedCard: FieldCard = FieldCard(card: newState.hand.remove(at: cardIndex), isTapped: (card as! MCardLand).comesInTapped, isSick: false)
            newState.battlefield.append(playedCard)
            newState.hasPlayedLand = true
            
            var result = Set<FieldState>()
            result.insert(newState)
            return result
        }//easy version for playing lands. TODO: OVERRIDE ONCE LANDS WITH COSTS HAPPEN
        
        //For non-land plays

        
        //First, get the set of our states with any/all lands tapped
        var poolTestStates: Set<FieldState> = self.allLandTapCombinations()
        for state in poolTestStates{
            if state.manaPool.canCoverCost(ofCard: card) == false{
                poolTestStates.remove(state)
            }//if that iteration of mana taps won't pay the cost, remove them from consideration
        }//for
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for state in poolTestStates{
            for costResult in state.manaPool.payCost(ofCard: card){
                let newState: FieldState = FieldState(state: state)
                newState.hand.remove(at: cardIndex)
                newState.manaPool = costResult
                if card.isCreature(){
                    newState.battlefield.append( FieldCard(card: card, isTapped: false, isSick: true))
                }
                else{
                    newState.battlefield.append( FieldCard(card: card, isTapped: false, isSick: false))
                }
                resultStates.insert(newState)
            }
        }
        
        //Only return the states that don't waste mana (no mana burn here!)
        let mostEfficient: FieldState = resultStates.min { (state1, state2) -> Bool in
            return state1.manaPool < state2.manaPool
        }!
        resultStates = resultStates.filter({ (state) -> Bool in
            return state.manaPool == mostEfficient.manaPool
        })
        
        
        
        return resultStates
    }//playCard
    
    
    /**
     Simulates all possible ways a turn could shape up from a given state. Only returns itself in the resultant set if there is no other play to make, which allows for recursion
     - returns: Set of all `FieldState` objects representing the possible outcomes of the current turn
    */
    public func allTurnResults() -> Set<FieldState>{
        var resultSet: Set<FieldState> = Set<FieldState>()//This is the resultant "down-the-tree" set, where we've iterated through all possibilities
        var progressSet: Set<FieldState> = Set<FieldState>()//This is the "after one play" set, where we don't yet iterate through

        for card in self.hand{
            if card.isLand() == false{
                var playThatCard: Set<FieldState>?
                do{
                    playThatCard = try self.playCard(card: card)
                }
                catch FieldStateError.cannotPayCost{//the other function call handles the "but what if we don't have the mana for that?"
                    playThatCard = nil
                }
                catch{
                    NSLog("Unexpected Error: \(error)")
                }
                
                progressSet = progressSet.union(playThatCard ?? Set<FieldState>())
                
            }//for any non-land cards
            else{
                if self.hasPlayedLand == false{
                    var playThatCard: Set<FieldState>?
                    do{
                        playThatCard = try self.playCard(card: card)
                    }
                    catch{
                        NSLog("Unexpected Error: \(error)")
                    }
                    
                    progressSet = progressSet.union(playThatCard ?? Set<FieldState>())
                }//if we haven't played the land yet
            }//for land cards
        }//for each card in hand
        
        if progressSet.count == 0{
            return Set<FieldState>([self])
        }//if we don't have any plays to make, return our own self
        for state in progressSet{
            resultSet = resultSet.union(state.allTurnResults())
        }
        
        
        return resultSet
    }//allTurnResults
    
    public func allLandTapCombinations() -> Set<FieldState>{
        //first, get indexes of our tappable lands
        var tappableIndexes: [Int] = []
        for i in 0 ..< self.battlefield.count{
            if !self.battlefield[i].isTapped && self.battlefield[i].card is MCardLand{
                tappableIndexes.append(i)
            }
        }
        
        let indexCombos: [[Int]] = tappableIndexes.allCombinations()
        
        var landTapCombos: Set<FieldState> = Set<FieldState>()
        let noTap: FieldState = FieldState(state: self)
        landTapCombos.insert(noTap)
        
        for combo in indexCombos{//each combination must have at least one value
            var toTapSet: Set<FieldState> = Set<FieldState>([self])
            var resultSet: Set<FieldState> = Set<FieldState>()
            for landIndex in combo{
                for state in toTapSet{
                    do{resultSet = resultSet.union(try state.tapLandAtIndex(index: landIndex))}catch{NSLog("\(error)")}//add to resultSet the results of tapping the next land in the toTapSet states
                }//for each variant
                toTapSet = resultSet
                resultSet = Set<FieldState>()
            }//for each land in each combo
            
            landTapCombos = landTapCombos.union(toTapSet)
        }//for each set of tappability combinations
        
        
        
        return landTapCombos
    }//allLandTapCombinations
    
    private func containsTappableLand() -> Bool{
        if battlefield.count == 0 {return false}
        return battlefield.filter({ (fieldCard) -> Bool in
            return !fieldCard.isTapped && fieldCard.card is MCardLand
        }).count > 0
    }//containsTappableLand
    
    /**
     Taps the land at a given battlefield index.
     - returns: A set of field states reflecting that land being tapped. Is a set containing all possible mana pools resulting from that tap
     */
    public func tapLandAtIndex(index: Int) throws -> Set<FieldState>{
        if self.battlefield.count == 0 || index < 0 || index >= battlefield.count{ throw FieldStateError.indexOOB(message: "Index \(index) out of bounds") }
        if (self.battlefield[index].card is MCardLand) == false{ throw FieldStateError.indexOOB(message: "Card at index \(index) is not a land card") }
        if (self.battlefield[index].isTapped){ throw FieldStateError.cannotPayCost(message: "Land at index \(index) is already tapped") }
        
        let landCard: MCardLand = self.battlefield[index].card as! MCardLand
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for possibleYield: ManaPool in landCard.possibleYields(){
            let newState: FieldState = FieldState(state: self)//make copy of current state
            
            newState.battlefield[index].isTapped = true //tap the land
            newState.manaPool = newState.manaPool + possibleYield //add that particular yield to the mana pool
            
            resultStates.insert(newState)
            
        }//for each possible mana pool yield
      
        return resultStates
    }//tapLandAtIndex
    
    public func possibleManaPoolsFromHand()->Set<ManaPool>{
        
        //make a fake FieldState (we won't worry about removing lands from the hand; we'll just put them out)
        let testState = FieldState(state: self)
        
        //Put all lands from hand onto battlefield
        for card in testState.hand{
            if card.isLand(){
                let newFieldCard = FieldCard(card: card, isTapped: false, isSick: false)
                testState.battlefield.append(newFieldCard)
            }
        }
        
        //untap anything on our battlefield
        for i in 0 ..< testState.battlefield.count{
            if testState.battlefield[i].isTapped{
                let newCard: FieldCard = FieldCard(card: testState.battlefield[i].card, isTapped: false, isSick: false)
                testState.battlefield[i] = newCard
            }
        }//for each card on the battlefield
        
        //see how all those untapped lands could possibly play out
        return testState.possibleManaPools()
    }//possibleManaPoolsFromHand
    
    public func possibleManaPools()->Set<ManaPool>{
        let currentManaPool = self.manaPool
        let untappedLands: [FieldCard] = battlefield.filter { (fieldCard) -> Bool in
            fieldCard.card.isLand() && !fieldCard.isTapped
        }
        var landCards: [MCardLand] = []
        for land in untappedLands{
            landCards.append(land.card as! MCardLand)
        }
        
        var result: Set<ManaPool> = Set<ManaPool>()
        result.insert(currentManaPool)
        
        for land in landCards{
            for pool in result{
                for possibleYield in land.possibleYields(){
                    let altPool = pool + possibleYield
                    result.insert(altPool)
                }//for each possible yield per land card
            }//for each currently possible pool
        }//for each land card
        
        return result
    }//possibleManaPools
    
    public var description: String{
        var handString = "\tHand: {"
        for card in self.hand{
            handString.append("[\(card.name)] ")
        }
        handString.append("}")
        var battlefieldString = "\tBattlefield: {"
        for card in self.battlefield{
            battlefieldString.append("\(card)")
        }
        battlefieldString.append("}")
        
        return "\t\(manaPool)\n\(handString)\n\(battlefieldString)\n"
    }//description
    
    internal struct FieldCard: CustomStringConvertible, Comparable, Hashable{
 
        var card: MCard
        var isTapped: Bool = false
        var isSick: Bool = false
        
        public var description: String{
            return "[\(card.name)\(isTapped ? ", tapped" : "" )]"
        }
        
        static func < (lhs: FieldState.FieldCard, rhs: FieldState.FieldCard) -> Bool {
            if lhs.card < rhs.card{ return true }
            if lhs.card >= rhs.card{ return false }
            if !lhs.isTapped && rhs.isTapped{ return true }
            return false
        }//operator <
        
    }//FieldCard
    
    //MARK: Card location business
    
    enum CardLocationType{
        case hand
        case battlefield
        case library
        case graveyard
        case exiled
    }//cardLocation
    
}//FieldState

struct CardLocation{
    
    var location: FieldState.CardLocationType = .exiled
    var index: Int?
    
}//CardLocation

enum FieldStateError: Error{
    case notInHand(message: String)
    case cannotPayCost(message: String)
    case noTwoLands(message: String)
    case indexOOB(message: String)
}//SimulatorError

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element: Equatable{
    func allCombinations() -> [[Element]]{
        if self.count == 0{
            return [[]]
        }
        
        var result: [[Element]] = [self]
        
        for i in 0 ..< self.count{
            var iCopy: Array<Element> = Array<Element>(self)
            iCopy.remove(at: i)
            for subArray in iCopy.allCombinations(){
                if subArray.count > 0 && !result.contains(subArray){
                    result.append(subArray)
                }
            }
            
        }//for each index
        
        return result
    }
}//Array Extension (combinations)
