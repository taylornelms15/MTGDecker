//
//  Simulator.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/7/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

/**
 Class used to test a Deck object against various Mulligan rules and Success rules.
 Meant to be reinitialized every time the composition of the deck changes; unknown properties if deck size increases or decreases while simulator operations happening
 */
internal class Simulator{
    
    ///The Deck object used to initialize the Simulator's deck; goal is to not mutate it during Simulator operations
    var deck: Deck
    ///The simulator's deck; preserves card position, represents discrete number of cards in case of copies (just like a physical deck does)
    var cards: [MCard]
    ///Represents the size of the simulator's deck
    var deckSize: Int
    
    internal init(deck: Deck){
        self.deck = deck
        let sortedDeck: [[(MCard, Int)]] = deck.getCardsSorted()
        self.deckSize = deck.getCardTotal()
        
        cards = Array<MCard>()
        
        for typeBlock in sortedDeck{//typeBlock: [(MCard, Int)]
            for cardTuple in typeBlock{//cardTuple: (MCard, Int)
                for _ in 0 ..< cardTuple.1{//_: one instance of MCard
                    cards.append(cardTuple.0)
                }//for each card
            }//for card tuple
        }//for type
    }//init
    
    //MARK: Inspectors
    
    /**
     Gives a sub-array of cards between two given indexes from the simulator's deck.
     - parameter fromIndex: starting index for hand pull; must be between 0 and deckSize - 1
     - parameter toIndex: ending index for hand pull; must be between fromIndex and deckSize - 1
     - returns: Array of MCard objects representing the cards between the given indexes in the simulator deck
     - throws: SimulatorError.cardIndexOOB if any card indexes are out of bounds
    */
    internal func pullOutHand(fromIndex: Int, toIndex: Int) throws -> [MCard]{
        if fromIndex < 0{ throw SimulatorError.cardIndexOOB(message: "Starting card index out of bounds (too low)") }
        if fromIndex >= deckSize{ throw SimulatorError.cardIndexOOB(message: "Starting card index out of bounds (too high)") }
        if toIndex < fromIndex{ throw SimulatorError.cardIndexOOB(message: "Ending card index out of bounds (lower than starting index)") }
        if toIndex >= deckSize{ throw SimulatorError.cardIndexOOB(message: "Ending card index out of bounds (too high)") }
        
        var resultArray: Array<MCard> = Array<MCard>()
        
        for i in fromIndex ... toIndex{
            resultArray.append(cards[i])
        }
        return resultArray
    }//pullOutHand
    
    
    //MARK: Deck Manipulators
    
    /**
     Sorts the contents of the simulator's deck. Does so by setting each element to an MCard from the Deck, using the Deck's sort order (default: by card type first, then alphabetically)
     */
    internal func sortSimulatorDeck(){
        let sortedDeck: [[(MCard, Int)]] = deck.getCardsSorted()
        var currentIndex: Int = 0
        
        for typeBlock in sortedDeck{//typeBlock: [(MCard, Int)]
            for cardTuple in typeBlock{//cardTuple: (MCard, Int)
                for _ in 0 ..< cardTuple.1{//_: one instance of MCard
                    cards[currentIndex] = cardTuple.0
                    currentIndex += 1
                }//for each card
            }//for card tuple
        }//for type
    }//sortSimulatorDeck
    
    /**
     Shuffles the contents of the simulator's deck
     */
    internal func shuffleDeck(){
        do{
            try self.shuffleDeck(startingAtCard: 0)
        }catch{
            NSLog("Error shuffling deck: \(error)")
        }
    }//shuffleDeck
    
    /**
     Shuffles the contents of the simulator's deck
     - parameter startingAtCard: The index of the card at which to start (supports shuffling "rest of deck" while ignoring current hand, for instance)
     */
    internal func shuffleDeck(startingAtCard: Int) throws{
        if startingAtCard < 0{ throw SimulatorError.cardIndexOOB(message: "Cannot shuffle cards that exist before the size of the deck") }
        if startingAtCard >= deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot start shuffling at a card past the end of the deck") }

        var i = deckSize - 1
        var temp: MCard? = nil
        var swapIndex: Int = 0
        
        while (i >= startingAtCard){
            //generate random index between the startingAtCard index and i
            swapIndex = startingAtCard + Int(arc4random_uniform(UInt32(i - startingAtCard + 1)))
            
            //swap the card at i with the card at the swapIndex
            temp = cards[swapIndex]
            cards[swapIndex] = cards[i]
            cards[i] = temp!
            
            //decrement i (looking to swap at a 1-reduced set of cards now)
            i -= 1
        }//while
        
        
    }//startingAtCard
    
    //MARK: Simulator functions
    
    /**
     Tests a hand of a given size against a given subcondition. Handles all relevant logic inside this class (as opposed to the Subcondition itself matching its conditions)
     - parameter handSize: The size of the hand to test against the subcondition. Without shuffling, tests this many cards from the top of the deck against this.
     - parameter subcondition: The subcondition against which we want to test the hand.
     - throws: Throws SimulatorError.cardIndexOOB if handSize is larger than the size of the deck, or less than 1
     - returns: Whether or not the hand passes the given subcondition
     */
    internal func testHandAgainstSubcondition(handSize: Int, subcondition: Subcondition) throws -> Bool{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        
        let myHand: [MCard] = try self.pullOutHand(fromIndex: 0, toIndex: handSize - 1)
        
        switch subcondition.type{
        case .landTotal:
            return testLandTotalSubcondition(subcondition, myHand)
        case .creatureTotal:
            return testCreatureTotalSubcondition(subcondition, myHand)
        case .planeswalkerTotal:
            return testPlaneswalkerTotalSubcondition(subcondition, myHand)
        case .artifactTotal:
            return testArtifactTotalSubcondition(subcondition, myHand)
        case .enchantmentTotal:
            return testEnchantmentTotalSubcondition(subcondition, myHand)
        case .instantTotal:
            return testInstantTotalSubcondition(subcondition, myHand)
        case .sorceryTotal:
            return testSorceryTotalSubcondition(subcondition, myHand)
        default:
            return false
        }//switch (by subcondition type)

    }//testHandAgainstSubcondition
    
    ///Tests if there are between numparam2 and numparam3 Land cards within the hand
    fileprivate func testLandTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isLand(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testLandTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Creature cards within the hand
    fileprivate func testCreatureTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isCreature(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testCreatureTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Planeswalker cards within the hand
    fileprivate func testPlaneswalkerTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isPlaneswalker(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testPlaneswalkerTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Artifact cards within the hand
    fileprivate func testArtifactTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isArtifact(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testArtifactTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Enchantment cards within the hand
    fileprivate func testEnchantmentTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isEnchantment(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testEnchantmentTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Instant cards within the hand
    fileprivate func testInstantTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isInstant(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testInstantTotalSubcondition
    ///Tests if there are between numparam2 and numparam3 Sorcery cards within the hand
    fileprivate func testSorceryTotalSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        
        var total: Int = 0
        for card in myHand{
            if card.isSorcery(){
                total += 1
            }
        }//for
        
        return (lowEnd <= total) && (highEnd >= total)
    }//testInstantTotalSubcondition
    
    
}//Simulator

enum SimulatorError: Error{
    case cardIndexOOB(message: String)
}//SimulatorError