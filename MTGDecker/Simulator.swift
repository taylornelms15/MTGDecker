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
    ///Represents the minimum mana coverage to play all cards in the deck
    private var costBlock: CostBlock
    
    
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
        
        costBlock = CostBlock()
        for card in cards{
            costBlock.addCostForCard(card: card)
        }//for each card, add it's costs to the costBlock
        
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
    internal func testHandAgainstCondition(handSize: Int, condition: Condition) throws -> Bool{
        if handSize < 0{ throw SimulatorError.cardIndexOOB(message: "Unable to test a hand with fewer than 1 card") }
        if handSize > deckSize{ throw SimulatorError.cardIndexOOB(message: "Cannot test more cards than exist in the deck") }
        
        if condition.subconditionList != nil && condition.subconditionList!.count != 0{
            for subcondition in condition.subconditionList!{
                if try self.testHandAgainstSubcondition(handSize: handSize, subcondition: subcondition) == false{
                    return false
                }//if any subconditions are not met, the condition is not met
            }//for each subcondition
            
            return true //if all subconditions are met,
        }//if we have subconditions
        else{
            throw SimulatorError.emptyTest(message: "Condition must have at least one valid subcondition to test")
        }//else (no subconditions in list)
        
    }//testHandAgainstCondition
    
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
        case .nameEqualTo:
            if subcondition.stringParam1 == nil{ throw SimulatorError.stringNotValid(message: "For nameEqualTo conditions, must have string value in stringParam1") }
            return testNameEqualToSubcondition(subcondition, myHand)
        case .cmcEqualTo:
            if subcondition.numParam1 == -1{ throw SimulatorError.stringNotValid(message: "For cmcEqualTo conditions, must have value greater than -1 in numParam1") }
            return testCmcEqualToSubcondition(subcondition, myHand)
        case .subtypeEqualTo:
            if subcondition.stringParam1 == nil{ throw SimulatorError.stringNotValid(message: "For subtypeEqualTo conditions, must have string value in stringParam1") }
            return testSubtypeEqualToSubcondition(subcondition, myHand)
        case .supertypeEqualTo:
            if subcondition.stringParam1 == nil{ throw SimulatorError.stringNotValid(message: "For supertypeEqualTo conditions, must have string value in stringParam1") }
            return testSupertypeEqualToSubcondition(subcondition, myHand)
        case .powerEqualTo:
            if subcondition.numParam1 == -1{ throw SimulatorError.stringNotValid(message: "For powerEqualTo conditions, must have value greater than -1 in numParam1") }
            return testPowerEqualToSubcondition(subcondition, myHand)
        case .toughnessEqualTo:
            if subcondition.numParam1 == -1{ throw SimulatorError.stringNotValid(message: "For toughnessEqualTo conditions, must have value greater than -1 in numParam1") }
            return testToughnessEqualToSubcondition(subcondition, myHand)
        case .playable:
            let state: FieldState = FieldState(deck: cards, handSize: handSize)//makes a virtual play field to test playabilty
            return testPlayabilitySubcondition(subcondition, state)
        case .manaCoverage:
            return testManaCoverageSubcondition(subcondition, myHand)
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
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose name is equal to stringParam1
    fileprivate func testNameEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let nameValue: String = subcondition.stringParam1!
        
        var total: Int = 0
        for card in myHand{
            if card.name == nameValue{
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testNameEqualToSubcondition
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose cmc is equal to numparam1
    fileprivate func testCmcEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let matchValue = subcondition.numParam1
        
        var total: Int = 0
        for card in myHand{
            if card.cmc == matchValue{
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testCmcEqualToSubcondition
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose name is equal to stringParam1
    fileprivate func testSubtypeEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let typeName: String = subcondition.stringParam1!
        
        var total: Int = 0
        for card in myHand{
            if card.subtypes != nil && card.subtypes!.contains(typeName){
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testSubtypeEqualToSubcondition
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose name is equal to stringParam1
    fileprivate func testSupertypeEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let typeName: String = subcondition.stringParam1!
        
        var total: Int = 0
        for card in myHand{
            if card.supertypes != nil && card.supertypes!.contains(typeName){
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testSubtypeEqualToSubcondition
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose power is equal to numparam1
    fileprivate func testPowerEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let matchValue = subcondition.numParam1
        
        var total: Int = 0
        for card in myHand{
            if card.power != nil && Int16(card.power!) != nil && Int16(card.power!) == matchValue{
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testPowerEqualToSubcondition
    ///Tests if there are between numparam2 and numparam3 cards within the hand whose power is equal to numparam1
    fileprivate func testToughnessEqualToSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool {
        let lowEnd = subcondition.numParam2
        let highEnd = subcondition.numParam3
        let matchValue = subcondition.numParam1
        
        var total: Int = 0
        for card in myHand{
            if card.toughness != nil && Int16(card.toughness!) != nil && Int16(card.toughness!) == matchValue{
                total += 1
            }
        }//for
        return (lowEnd <= total) && (highEnd >= total)
    }//testPowerEqualToSubcondition
    ///Tests playability of a card specified
    fileprivate func testPlayabilitySubcondition(_ subcondition: Subcondition, _ state: FieldState) -> Bool{
        let hand: [MCard] = Array<MCard>(state.hand)
        var targetCards: Set<MCard> = Set<MCard>()
        if subcondition.stringParam1 != nil{
            if let target: MCard = hand.first(where: { (card) -> Bool in
                card.name == subcondition.stringParam1
            }){
                targetCards.insert(target)
            }//if the hand has a card with a name match, put it in the list of targets
        }//if we're looking for a card with a given name
        else{
            switch subcondition.typeParam{
                case .none:
                    NSLog("Somehow ended up seaching for playability of a non-extant card type")//TODO: error-handle this better
                    return false
                case .land:
                    for card in hand{
                        if card.isLand(){
                            targetCards.insert(card)
                        }
                    }
                case .creature:
                    for card in hand{
                        if card.isCreature(){
                            targetCards.insert(card)
                        }
                    }
                case .planeswalker:
                    for card in hand{
                        if card.isPlaneswalker(){
                            targetCards.insert(card)
                        }
                    }
                case .artifact:
                    for card in hand{
                        if card.isArtifact(){
                            targetCards.insert(card)
                        }
                    }
                case .enchantment:
                    for card in hand{
                        if card.isEnchantment(){
                            targetCards.insert(card)
                        }
                    }
                case .instant:
                    for card in hand{
                        if card.isInstant(){
                            targetCards.insert(card)
                        }
                    }
                case .sorcery:
                    for card in hand{
                        if card.isSorcery(){
                            targetCards.insert(card)
                        }
                    }
            }//if we're looking for cards with a given type
        }//else
        
        //for all of our target cards, see if we could feasibly play them
        for target in targetCards{
            if state.manaPool.canCoverCost(ofCard: target){
                return true//return true for lands or 0-cost cards
            }
            
            let possiblePools: Set<ManaPool> = state.possibleManaPoolsFromHand()
            for possibility in possiblePools{
                if possibility.canCoverCost(ofCard: target){
                    return true
                }//if that possible mana yield could play the target card
            }//for each possible mana yield from all lands in hand
        }//for each "success if playable" target card
            
        
        
        return false
    }//testPlayabilitySubcondition
    ///Tests mana coverage of lands in hand
    fileprivate func testManaCoverageSubcondition(_ subcondition: Subcondition, _ myHand: [MCard]) -> Bool{
        let testBlock: CostBlock = CostBlock(block: self.costBlock)//makes a copy of the deck's cost block to test against
        
        let lands: [MCardLand] = myHand.filter { (card) -> Bool in
            return card is MCardLand
        } as? [MCardLand] ?? [] //gives us either an array of [MCardLand], or []
        
        for landCard in lands{
            testBlock.subCostForLand(land: landCard)
        }//for each land in hand
        
        return testBlock.isEmpty()//if we've covered all the deck's mana cost colors within the current hand, we're set
        
    }//testManaCoverageSubcondition
    
    private class CostBlock: CustomStringConvertible{
        
        var w: Bool = false
        var u: Bool = false
        var b: Bool = false
        var r: Bool = false
        var g: Bool = false
        var c: Bool = false
        var any: Bool = false
        var wu: Bool = false
        var ub: Bool = false
        var br: Bool = false
        var rg: Bool = false
        var gw: Bool = false
        var wb: Bool = false
        var ur: Bool = false
        var bg: Bool = false
        var rw: Bool = false
        var gu: Bool = false
        
        init(){
            
        }//default initializer
        
        init(block: CostBlock){
            self.w = block.w
            self.u = block.u
            self.b = block.b
            self.r = block.r
            self.g = block.g
            self.c = block.c
            self.any = block.any
            self.wu = block.wu
            self.ub = block.ub
            self.br = block.br
            self.rg = block.rg
            self.gw = block.gw
            self.wb = block.wb
            self.ur = block.ur
            self.bg = block.bg
            self.rw = block.rw
            self.gu = block.gu
        }//init from another block
        
        var description: String{
            var result: String = "["
            if w {result += " w"}
            if u {result += " u"}
            if b {result += " b"}
            if r {result += " r"}
            if g {result += " g"}
            if c {result += " c"}
            if any {result += " any"}
            if wu {result += " wu"}
            if ub {result += " ub"}
            if br {result += " br"}
            if rg {result += " rg"}
            if gw {result += " gw"}
            if wb {result += " wb"}
            if ur {result += " ur"}
            if bg {result += " bg"}
            if rw {result += " rw"}
            if gu {result += " gu"}
            result += " ]"
            
            return result
        }//description
        
        func isEmpty()->Bool{
            return !w && !u && !b && !r && !g && !c && !any && !wu && !ub && !br && !rg && !gw && !wb && !ur && !bg && !rw && !gu
        }
        
        func addCostForCard(card: MCard){
            if card.whiteCost       > 0 {self.w = true}
            if card.blueCost        > 0 {self.u = true}
            if card.blackCost       > 0 {self.b = true}
            if card.redCost         > 0 {self.r = true}
            if card.greenCost       > 0 {self.g = true}
            if card.colorlessCost   > 0 {self.c = true}
            if card.anymanaCost     > 0 {self.any = true}
            if card.whiteblueCost   > 0 {self.wu = true}
            if card.blueblackCost   > 0 {self.ub = true}
            if card.blackredCost    > 0 {self.br = true}
            if card.redgreenCost    > 0 {self.rg = true}
            if card.greenwhiteCost  > 0 {self.gw = true}
            if card.whiteblackCost  > 0 {self.wb = true}
            if card.blueredCost     > 0 {self.ur = true}
            if card.blackgreenCost  > 0 {self.bg = true}
            if card.redwhiteCost    > 0 {self.rw = true}
            if card.greenblueCost   > 0 {self.gu = true}
        }//addCostForCard
        
        func subCostForLand(land: MCardLand){
            if self.isEmpty(){return}//don't bother going through this noise if we're already covered
            if land.wYield > 0{
                self.subCostWhite()
            }
            if land.uYield > 0{
                self.subCostBlue()
            }
            if land.bYield > 0{
                self.subCostBlack()
            }
            if land.rYield > 0{
                self.subCostRed()
            }
            if land.gYield > 0{
                self.subCostGreen()
            }
            if land.cYield > 0{
                self.subCostColorless()
            }
            if land.anyYield > 0{
                self.subCostWhite()
                self.subCostBlue()
                self.subCostBlack()
                self.subCostRed()
                self.subCostGreen()
                self.subCostColorless()
            }
            if land.wuYield != 0{
                if land.wuYield > 0{
                    self.subCostWhite()
                    self.subCostBlue()
                }
                else{
                    self.subCostBlack()
                    self.subCostRed()
                    self.subCostGreen()
                }
            }//if WUYield
            if land.ubYield != 0{
                if land.ubYield > 0{
                    self.subCostBlack()
                    self.subCostBlue()
                }
                else{
                    self.subCostWhite()
                    self.subCostRed()
                    self.subCostGreen()
                }
            }//if UBYield
            if land.brYield != 0{
                if land.brYield > 0{
                    self.subCostBlack()
                    self.subCostRed()
                }
                else{
                    self.subCostWhite()
                    self.subCostBlue()
                    self.subCostGreen()
                }
            }//if BRYield
            if land.rgYield != 0{
                if land.rgYield > 0{
                    self.subCostGreen()
                    self.subCostRed()
                }
                else{
                    self.subCostWhite()
                    self.subCostBlue()
                    self.subCostBlack()
                }
            }//if RGYield
            if land.gwYield != 0{
                if land.gwYield > 0{
                    self.subCostGreen()
                    self.subCostWhite()
                }
                else{
                    self.subCostRed()
                    self.subCostBlue()
                    self.subCostBlack()
                }
            }//if GWYield
            if land.wbYield != 0{
                if land.wbYield > 0{
                    self.subCostBlack()
                    self.subCostWhite()
                }
                else{
                    self.subCostRed()
                    self.subCostBlue()
                    self.subCostGreen()
                }
            }//if WBYield
            if land.urYield != 0{
                if land.urYield > 0{
                    self.subCostBlue()
                    self.subCostRed()
                }
                else{
                    self.subCostWhite()
                    self.subCostBlack()
                    self.subCostGreen()
                }
            }//if URYield
            if land.bgYield != 0{
                if land.bgYield > 0{
                    self.subCostBlack()
                    self.subCostGreen()
                }
                else{
                    self.subCostRed()
                    self.subCostBlue()
                    self.subCostWhite()
                }
            }//if BGYield
            if land.rwYield != 0{
                if land.rwYield > 0{
                    self.subCostWhite()
                    self.subCostRed()
                }
                else{
                    self.subCostBlue()
                    self.subCostBlack()
                    self.subCostGreen()
                }
            }//if RWYield
            if land.guYield != 0{
                if land.guYield > 0{
                    self.subCostBlue()
                    self.subCostGreen()
                }
                else{
                    self.subCostRed()
                    self.subCostBlack()
                    self.subCostWhite()
                }
            }//if GUYield
        }//subCostForLand
        
        func subCostWhite(){
            self.w = false
            self.wu = false
            self.gw = false
            self.wb = false
            self.rw = false
            self.any = false
        }//subCostWhite
        func subCostBlue(){
            self.u = false
            self.wu = false
            self.ub = false
            self.gu = false
            self.ur = false
            self.any = false
        }//subCostBlue
        func subCostBlack(){
            self.b = false
            self.wb = false
            self.ub = false
            self.br = false
            self.bg = false
            self.any = false
        }//subCostBlack
        func subCostRed(){
            self.r = false
            self.rw = false
            self.ur = false
            self.br = false
            self.rg = false
            self.any = false
        }//subCostRed
        func subCostGreen(){
            self.g = false
            self.gw = false
            self.gu = false
            self.bg = false
            self.rg = false
            self.any = false
        }//subCostGreen
        func subCostColorless(){
            self.c = false
            self.any = false
        }//subCostColorless
        
    }//CostBlock
    
}//Simulator


enum SimulatorError: Error{
    case cardIndexOOB(message: String)
    case stringNotValid(message: String)
    case emptyTest(message: String)
}//SimulatorError
