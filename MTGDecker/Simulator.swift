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
    
    static var NUM_THREADS: Int = 16
    
    ///The Deck object used to initialize the Simulator's deck; goal is to not mutate it during Simulator operations
    var deck: Deck
    ///The simulator's deck; preserves card position, represents discrete number of cards in case of copies (just like a physical deck does)
    var cards: [MCard]
    ///Represents the size of the simulator's deck
    var deckSize: Int
    ///Represents the minimum mana coverage to play all cards in the deck
    internal var costBlock: CostBlock
    ///A record of the NSManagedObjectContext that this particular simulator is pulling from
    internal var context: NSManagedObjectContext
    
    
    internal init(deck: Deck, intoContext: NSManagedObjectContext){
        self.deck = intoContext.object(with: deck.objectID) as! Deck
        let sortedDeck: [[(MCard, Int)]] = deck.getCardsSorted()
        self.deckSize = deck.getCardTotal()
        
        cards = Array<MCard>()
        
        for typeBlock in sortedDeck{//typeBlock: [(MCard, Int)]
            for cardTuple in typeBlock{//cardTuple: (MCard, Int)
                for _ in 0 ..< cardTuple.1{//_: one instance of MCard
                    cards.append(intoContext.object(with: cardTuple.0.objectID) as! MCard)
                }//for each card
            }//for card tuple
        }//for type
        
        costBlock = CostBlock()
        for card in cards{
            costBlock.addCostForCard(card: card)
        }//for each card, add it's costs to the costBlock
        
        self.context = intoContext
        
    }//init
    internal init(simulator: Simulator, intoContext: NSManagedObjectContext){
        self.cards = Array<MCard>()
        self.costBlock = simulator.costBlock
        //self.deck = simulator.deck
        self.deck = intoContext.object(with: simulator.deck.objectID) as! Deck
        
        for card in simulator.cards{
            //self.cards.append(card)
            self.cards.append(intoContext.object(with: card.objectID) as! MCard)
        }
        
        self.deckSize = self.cards.count
        self.context = intoContext
    }//init (quick-copy)
    
    
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
    
    /**
     Presents a String representation of the internal CostBlock object (a private class)
     - returns: String representation of all mana costs represented in the deck
    */
    public func costBlockDescription()->String{
        return "\(self.costBlock)"
    }//costBlockDescription
    
    
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
     Tests a deck against the given set of mulligan rules a given number of times. Defaults to a 7-card hand draw initially.
    */
    internal func testDeckAgainstMulliganMultiple(ruleset: MulliganRuleset, repetitions: Int, success: SuccessRule? = nil) -> SimulationResult{
        NotificationCenter.default.post(name: .simulatorStartedNotification , object: nil)
        
        var result: SimulationResult = SimulationResult()
        let simulatorGroup: DispatchGroup = DispatchGroup()
        let resultQueue: DispatchQueue = DispatchQueue(label: "Simulation Result")//protects the result variable
        
        let threadSplit: [Int] = Simulator.repetitionSplit(repetitions: repetitions, numThreads: Simulator.NUM_THREADS)
        
        for i in threadSplit{ //i == number of sub-repetitions
            simulatorGroup.enter()

            DispatchQueue.global(qos: .userInitiated).async {
                let testContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                testContext.parent = self.context
                let testRuleset: MulliganRuleset = testContext.object(with: ruleset.objectID) as! MulliganRuleset
                let testSimulator: Simulator = Simulator(simulator: self, intoContext: testContext)
                
                var subResult: SimulationResult = SimulationResult()
                
                for _ in 0 ..< i{
                    testSimulator.shuffleDeck()
                    do{
                        let testResult: SimulationResult = try testSimulator.testDeckAgainstMulliganRuleset(ruleset: testRuleset, handSize: 7, success: success)
                        subResult += testResult
                    } catch{
                        NSLog("Error testing the deck a bunch: \(error)")
                    }
                    
                }//for each of the i sub-repetitions
                
                resultQueue.sync {
                    result += subResult
                    NotificationCenter.default.post(name: .simulatorProgressNotification , object: Float(result.numTrials) / Float(repetitions))
                }//result update queue
                
                simulatorGroup.leave()
               
            }//asynchronous simulation thread
            
        }//for each thread

        
        simulatorGroup.wait()//wait for all the repetitions to finish
        
        NotificationCenter.default.post(name: .simulatorEndedNotification , object: nil)
        
        return result
        
    }//testDeckAgainstMulliganMultiple
    
    /**
     Tests the deck against a set of Mulligan Rules. Returns a SimulationResult obect that contains, essentially, what size the hand was when it was accepted, given the set of rules. Note: operates recursively, reducing handSize until it lands on a 3-card hand (woof), which it automatically accepts. This behavior cannot be changed.
     - parameter ruleset: The `MulliganRuleset` against which to run the draw.
     - parameter handSize: the size of the hand to draw off the current deck.
     - returns: A `SimulationResult` object encapsulating the relevant metadata of how that particular hand draw operated
     */
    internal func testDeckAgainstMulliganRuleset(ruleset: MulliganRuleset, handSize: Int, success: SuccessRule? = nil) throws -> SimulationResult{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        if handSize > 7{ throw SimulatorError.cardIndexOOB(message: "Mulligan rules not supported for hand sizes larger than 7") }
        if handSize < 3{ throw SimulatorError.cardIndexOOB(message: "Mulligan rules not supported for hand sizes smaller than 3") }
        
        switch handSize{
        case 7:
            if ruleset.keepRule7 != nil{
                if try self.testHandAgainstKeepRule(handSize: handSize, keeprule: ruleset.keepRule7!){
                    let result: SimulationResult = SimulationResult()
                    result.numTrials = 1
                    result.card7Keeps = 1
                    
                    if success != nil{
                        if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                            result.card7Success = 1
                        }
                    }//if we have a success rule
                    
                    return result
                }//if we pass the test
                else{
                    self.shuffleDeck()
                    return try self.testDeckAgainstMulliganRuleset(ruleset: ruleset, handSize: handSize - 1, success: success) //recurse down to the smaller size
                }//if we don't pass the test
            }//if we have a keepRule7
            else{
                let result: SimulationResult = SimulationResult()
                result.numTrials = 1
                result.card7Keeps = 1
                
                if success != nil{
                    if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                        result.card7Success = 1
                    }
                }//if we have a success rule
                
                return result
            }//if there isn't a rule for 7-card hands, keep all 7-card hands
        case 6:
            if ruleset.keepRule6 != nil{
                if try self.testHandAgainstKeepRule(handSize: handSize, keeprule: ruleset.keepRule6!){
                    let result: SimulationResult = SimulationResult()
                    result.numTrials = 1
                    result.card6Keeps = 1
                    
                    if success != nil{
                        if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                            result.card6Success = 1
                        }
                    }//if we have a success rule
                    
                    return result
                }//if we pass the test
                else{
                    self.shuffleDeck()
                    return try self.testDeckAgainstMulliganRuleset(ruleset: ruleset, handSize: handSize - 1, success: success) //recurse down to the smaller size
                }
            }
            else{
                let result: SimulationResult = SimulationResult()
                result.numTrials = 1
                result.card6Keeps = 1
                
                if success != nil{
                    if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                        result.card6Success = 1
                    }
                }//if we have a success rule
                
                return result
        }//if there isn't a rule for 6-card hands, keep all 6-card hands
        case 5:
            if ruleset.keepRule5 != nil{
                if try self.testHandAgainstKeepRule(handSize: handSize, keeprule: ruleset.keepRule5!){
                    let result: SimulationResult = SimulationResult()
                    result.numTrials = 1
                    result.card5Keeps = 1
                    
                    if success != nil{
                        if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                            result.card5Success = 1
                        }
                    }//if we have a success rule
                    
                    return result
                }//if we pass the test
                else{
                    self.shuffleDeck()
                    return try self.testDeckAgainstMulliganRuleset(ruleset: ruleset, handSize: handSize - 1, success: success) //recurse down to the smaller size
                }
            }
            else{
                let result: SimulationResult = SimulationResult()
                result.numTrials = 1
                result.card5Keeps = 1
                
                if success != nil{
                    if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                        result.card5Success = 1
                    }
                }//if we have a success rule
                
                return result
        }//if there isn't a rule for 6-card hands, keep all 6-card hands
        case 4:
            if ruleset.keepRule4 != nil{
                if try self.testHandAgainstKeepRule(handSize: handSize, keeprule: ruleset.keepRule4!){
                    let result: SimulationResult = SimulationResult()
                    result.numTrials = 1
                    result.card4Keeps = 1
                    
                    if success != nil{
                        if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                            result.card4Success = 1
                        }
                    }//if we have a success rule
                    
                    return result
                }//if we pass the test
                else{
                    self.shuffleDeck()
                    return try self.testDeckAgainstMulliganRuleset(ruleset: ruleset, handSize: handSize - 1, success: success) //recurse down to the smaller size
                }
            }
            else{
                let result: SimulationResult = SimulationResult()
                result.numTrials = 1
                result.card4Keeps = 1
                
                if success != nil{
                    if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                        result.card4Success = 1
                    }
                }//if we have a success rule
                
                return result
        }//if there isn't a rule for 6-card hands, keep all 6-card hands
        case 3://hard default to "accept all 3-card hands"
            let result: SimulationResult = SimulationResult()
            result.numTrials = 1
            result.card3Keeps = 1
            
            if success != nil{
                if try self.testHandAgainstSuccessRule(handSize: handSize, successrule: success!){
                    result.card3Success = 1
                }
            }//if we have a success rule
            
            return result
        default: throw SimulatorError.cardIndexOOB(message: "Mulligan rules not supported for hand sizes larger than 7 or smaller than 3")
            
        }//which hand size
    }//testDeckAgainstMulliganRuleset
    
    /**
     Tests a hand of a given size against a given Success Rule. Throws most of the heavy lifting to the testHandAgainstCondition function
     
     Notably, this differs from testing conditions in that subconditions are AND'ed together, while conditions are OR'd together, for the purposes of evaluating rules.
     - parameter handSize: The size of the hand to test against the subcondition. Without shuffling, tests this many cards from the top of the deck against this.
     - parameter successrule: The Success Rule against which we want to test the hand.
     - returns: Whether or not the hand passes the given condition
     */
    internal func testHandAgainstSuccessRule(handSize: Int, successrule: SuccessRule) throws -> Bool{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        
        if successrule.conditionList != nil && successrule.conditionList!.count != 0{
            for condition in successrule.conditionList!{
                do{
                    if try self.testHandAgainstCondition(handSize: handSize, condition: condition, lookingForward: true){
                        return true
                    }//if passes the condition
                }
                catch{
                    NSLog("Error testing condition. Handsize: \(handSize), Error: \(error)")
                }
            }//for each condition
            
            return false //there were conditions tested, but none met
            
        }//if rule has
        else{
            return true //empty success rule == "keep all hands"
        }//else (no subconditions in list)
        
    }//testHandAgainstSuccessRule
    
    /**
     Tests a hand of a given size against a given Keep Rule. Throws most of the heavy lifting to the testHandAgainstCondition function
     
     Notably, this differs from testing conditions in that subconditions are AND'ed together, while conditions are OR'd together, for the purposes of evaluating rules.
     - parameter handSize: The size of the hand to test against the subcondition. Without shuffling, tests this many cards from the top of the deck against this.
     - parameter keeprule: The Keep Rule against which we want to test the hand.
     - returns: Whether or not the hand passes the given condition
     */
    internal func testHandAgainstKeepRule(handSize: Int, keeprule: KeepRule) throws -> Bool{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        
        if keeprule.conditionList != nil && keeprule.conditionList!.count != 0{
            for condition in keeprule.conditionList!{
                do{
                    if try self.testHandAgainstCondition(handSize: handSize, condition: condition){
                        return true
                    }//if passes the condition
                }
                catch{
                    NSLog("Error testing condition. Handsize: \(handSize), Error: \(error)")
                }
            }//for each condition
            
            return false //there were conditions tested, but none met
            
        }//if rule has
        else{
            return true //empty keep rule == "keep all hands"
        }//else (no subconditions in list)

    }//testHandAgainstKeepRule
    
    /**
     Tests a hand of a given size against a given condition. Throws most of the heavy lifting to the testHandAgainstSubcondition function
     - parameter handSize: The size of the hand to test against the subcondition. Without shuffling, tests this many cards from the top of the deck against this.
     - parameter condition: The subcondition against which we want to test the hand.
     - throws: Throws SimulatorError.cardIndexOOB if handSize is larger than the size of the deck, or less than 1
     - returns: Whether or not the hand passes the given condition
     */
    internal func testHandAgainstCondition(handSize: Int, condition: Condition, lookingForward: Bool = false) throws -> Bool{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        
        if condition.subconditionList != nil{
            if condition.subconditionList!.count != 0{
                for subcondition in condition.subconditionList!{
                    if try self.testHandAgainstSubcondition(handSize: handSize, subcondition: subcondition, lookingForward: lookingForward) == false{
                        return false
                    }//if any subconditions are not met, the condition is not met
                }//for each subcondition
            
                return true //if all subconditions are met,
            }//if
            else{
                return true
            }
        }//if we have subconditions
        else{
            return true //automatically accept all empty conditions
            //throw SimulatorError.emptyTest(message: "Condition must have at least one valid subcondition to test")
        }//else (no subconditions in list)
        
    }//testHandAgainstCondition
    
   /**
    Splits a given number of repetitions (such as simulations to run) across a given number of threads, so that work may be divided evenly
     - parameter repetitions: The number of work-item repetitions to split up
     - parameter numThreads: The number of threads on which to split the repetitions
     - returns: An array of size `numThreads` such that the sum of each of the elements is equal to `repetitions`
     */
    private static func repetitionSplit(repetitions: Int, numThreads: Int) -> [Int]{
        let baseRep: Int = repetitions / numThreads//base number of repetitions per thread
        let numCarryTheOne: Int = repetitions % numThreads//the number of threads that get one extra run
        var arrayFirsthalf: [Int] = Array<Int>(repeating: baseRep + 1, count: numCarryTheOne)
        let arraySecondhalf: [Int] = Array<Int>(repeating: baseRep, count: numThreads - numCarryTheOne)
        
        for value in arraySecondhalf{
            arrayFirsthalf.append(value)
        }
        
        return arrayFirsthalf
    }//repetitionSplit
    
}//Simulator


enum SimulatorError: Error{
    case cardIndexOOB(message: String)
    case stringNotValid(message: String)
    case emptyTest(message: String)
}//SimulatorError
