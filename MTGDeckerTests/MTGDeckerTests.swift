//
//  MTGDeckerTests.swift
//  MTGDeckerTests
//
//  Created by Taylor Nelms on 3/23/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import XCTest
import CoreData
import MTGSDKSwift
@testable import MTGDecker

///The number of runs to do on sets of randomized test runs (higher number yields a greater chance of edge-case catches, at the cost of taking more time
let TEST_ITER_COUNT: Int = 50

class MTGDeckerTests: XCTestCase {
    
    let magic: Magic = Magic();
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! MTGDecker.AppDelegate).persistentContainer.viewContext
    let cardAddGroup: DispatchGroup = DispatchGroup()
    var ratDeck: Deck? = nil
    var elfDeck: Deck? = nil
    var nayaDeck: Deck? = nil
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType /*.mainQueueConcurrencyType*/)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    override func setUp() {
        super.setUp()
        
        self.context = setUpInMemoryManagedObjectContext()
        
        let deckEntity: NSEntityDescription = Deck.entityDescription(context: context)
        ratDeck = Deck(entity: deckEntity, insertInto: context)
        ratDeck!.name = "Rat Deck"
        let ratBuilder: DeckBuilder = DeckBuilder(inContext: context, deck: ratDeck!)
        elfDeck = Deck(entity: deckEntity, insertInto: context)
        elfDeck!.name = "Elf Deck"
        let elfBuiler: DeckBuilder = DeckBuilder(inContext: context, deck: elfDeck!)
        nayaDeck = Deck(entity: deckEntity, insertInto: context)
        nayaDeck!.name = "Naya Deck"
        let nayaBuilder: DeckBuilder = DeckBuilder(inContext: context, deck: nayaDeck!)
        
        NotificationCenter.default.addObserver(forName: .cardAddNotification, object: nil, queue: nil) { (notification) in
            self.weHaveCardsNow(cardName: (notification.object as! String))
        }
        NotificationCenter.default.addObserver(forName: .cardImageAddNotification, object: nil, queue: nil) { (notification) in
            self.weHavePicsNow(card: (notification.object as! MCard))
        }
        
        
        let ratNames: [String] = ["Swamp", "Relentless Rats"]
        let elfNames: [String] = ["Forest", "Llanowar Elves", "Elvish Mystic", "Arbor Elf", "Elvish Archdruid", "Bow of Nylea", "Traveler\'s Amulet", "Naturalize", "Harvest Season", "Alloy Myr", "Nissa Revane"]
        let nayaNames: [String] = ["Naya Hushblade", "Forest", "Plains", "Mountain", "Jungle Shrine", "Wind-Scarred Crag", "Rugged Highlands", "Blossoming Sands", "Mayael\'s Aria", "Mutagenic Growth", "Naya Charm", "Selesnya Guildmage", "Ghalta, Primal Hunger"]
        
        for name in ratNames{
            cardAddGroup.enter()//one for the card
            cardAddGroup.enter()//another for the picture
            DispatchQueue.global().async {
                ratBuilder.addCardByName(name)
            }
        }//for each rat name, find the card
        
        for name in elfNames{
            cardAddGroup.enter()//one for the card
            cardAddGroup.enter()//another for the picture
            DispatchQueue.global().async {
                elfBuiler.addCardByName(name)
            }
        }//for each elf name, find the card
        
        for name in nayaNames{
            cardAddGroup.enter()//one for the card
            cardAddGroup.enter()//another for the picture
            DispatchQueue.global().async {
                nayaBuilder.addCardByName(name)
            }
        }//for each elf name, find the card
 
        cardAddGroup.wait()
        
        if !ratDeck!.changeCardQuantity(ofCardNamed: "Swamp", toQuantity: 24, context: context){
            NSLog("Error changing quantity at line \(#line)")
        }
        if !ratDeck!.changeCardQuantity(ofCardNamed: "Relentless Rats", toQuantity: 36, context: context){
            NSLog("Error changing quantity at line \(#line)")
        }
        
        
        for elfName in elfNames{
            if !elfDeck!.changeCardQuantity(ofCardNamed: elfName, toQuantity: 4, context: context){
                NSLog("Error changing quantity at line \(#line)")
                NSLog("Card name: \(elfName)")
            }
        }
        if !elfDeck!.changeCardQuantity(ofCardNamed: "Forest", toQuantity: 24, context: context){
            NSLog("Error changing quantity at line \(#line)")
        }
        if !elfDeck!.changeCardQuantity(ofCardNamed: "Nissa Revane", toQuantity: 2, context: context){
            NSLog("Error changing quantity at line \(#line)")
        }
        
        for nayaName in nayaNames{
            if !nayaDeck!.changeCardQuantity(ofCardNamed: nayaName, toQuantity: 4, context: context){
                NSLog("Error changing quantity at line \(#line)")
                NSLog("Card name: \(nayaName)")
            }
        }
        
        
        
    }//setUp
    
    func weHaveCardsNow(cardName: String){
        cardAddGroup.leave()
    
    }//weHaveCardsNow
    func weHavePicsNow(card: MCard){
        cardAddGroup.leave()
        
    }//weHaveCardsNow
    
    override func tearDown() {
        
        context.delete(ratDeck!)
        context.delete(elfDeck!)
        
        context.performAndWait {
            do{
                try self.context.save()
            }
            catch{
                
            }
        }
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }//tearDown
    

    
    func testDecks() {
        
        let ratSimulator: Simulator = Simulator(deck: ratDeck!)
        let elfSimulator: Simulator = Simulator(deck: elfDeck!)
        let nayaSimulator: Simulator = Simulator(deck: nayaDeck!)
        
        XCTAssert(ratSimulator.deckSize == 60)
        XCTAssert(elfSimulator.deckSize == 62)
        
        XCTAssertThrowsError(try ratSimulator.shuffleDeck(startingAtCard: -1))
        XCTAssertThrowsError(try ratSimulator.shuffleDeck(startingAtCard: 60))
        XCTAssertNoThrow(try ratSimulator.shuffleDeck(startingAtCard: 0))
        
        var myHand: [MCard] = Array<MCard>()
        
        XCTAssertThrowsError(try myHand = ratSimulator.pullOutHand(fromIndex: 0, toIndex: -1))
        XCTAssertThrowsError(try myHand = ratSimulator.pullOutHand(fromIndex: -1, toIndex: 6))
        XCTAssertThrowsError(try myHand = ratSimulator.pullOutHand(fromIndex: 5, toIndex: 4))
        XCTAssertThrowsError(try myHand = ratSimulator.pullOutHand(fromIndex: 0, toIndex: 60))
        XCTAssertThrowsError(try myHand = ratSimulator.pullOutHand(fromIndex: 60, toIndex: 60))
        XCTAssertNoThrow(try myHand = ratSimulator.pullOutHand(fromIndex: 0, toIndex: 0))
        XCTAssertNoThrow(try myHand = ratSimulator.pullOutHand(fromIndex: 59, toIndex: 59))
        XCTAssertNoThrow(try myHand = ratSimulator.pullOutHand(fromIndex: 0, toIndex: 6))
        
        XCTAssert(myHand.count == 7)
        
        XCTAssertNoThrow(try myHand = elfSimulator.pullOutHand(fromIndex: 0, toIndex: 6))
        elfSimulator.shuffleDeck()
        XCTAssertNoThrow(try myHand = elfSimulator.pullOutHand(fromIndex: 0, toIndex: 6))
        


        let landCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        landCondition.type = .landTotal
        landCondition.numParam2 = 2
        landCondition.numParam3 = 5
        let landNames: [String] = ["Forest"]//The only land in the whole bunch
        
        let creatureCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        creatureCondition.type = .creatureTotal
        creatureCondition.numParam2 = 1
        creatureCondition.numParam3 = 3
        let creatureNames: [String] = ["Llanowar Elves", "Elvish Mystic", "Arbor Elf", "Elvish Archdruid", "Alloy Myr"]
        
        let pwCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        pwCondition.type = .planeswalkerTotal
        pwCondition.numParam2 = 1
        pwCondition.numParam3 = 1
        let pwNames: [String] = ["Nissa Revane"]
        
        let artifactCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        artifactCondition.type = .artifactTotal
        artifactCondition.numParam2 = 2
        artifactCondition.numParam3 = 4
        let artifactNames: [String] = ["Traveler\'s Amulet", "Alloy Myr", "Bow of Nylea"]
        
        let enchantmentCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        enchantmentCondition.type = .enchantmentTotal
        enchantmentCondition.numParam2 = 1
        enchantmentCondition.numParam3 = 2
        let enchantmentNames: [String] = ["Bow of Nylea"]
        
        let instantCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        instantCondition.type = .instantTotal
        instantCondition.numParam2 = 0
        instantCondition.numParam3 = 2
        let instantNames: [String] = ["Naturalize"]
        
        let sorceryCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        sorceryCondition.type = .sorceryTotal
        sorceryCondition.numParam2 = 0
        sorceryCondition.numParam3 = 1
        let sorceryNames: [String] = ["Harvest Season"]
        
        let nameCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        nameCondition.type = .nameEqualTo
        nameCondition.stringParam1 = "Elvish Mystic"
        nameCondition.numParam2 = 0
        nameCondition.numParam3 = 2
        let nameNames: [String] = ["Elvish Mystic"]
        
        let cmcCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        cmcCondition.type = .cmcEqualTo
        cmcCondition.numParam1 = 3
        cmcCondition.numParam2 = 1
        cmcCondition.numParam3 = 3
        let cmcNames: [String] = ["Elvish Archdruid", "Alloy Myr", "Bow of Nylea", "Harvest Season"]
        
        let supertypeCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        supertypeCondition.type = .supertypeEqualTo
        supertypeCondition.stringParam1 = "Legendary"
        supertypeCondition.numParam2 = 0
        supertypeCondition.numParam3 = 1
        let supertypeNames: [String] = ["Bow of Nylea", "Nissa Revane"]
        
        let subtypeCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        subtypeCondition.type = .subtypeEqualTo
        subtypeCondition.stringParam1 = "Elf"
        subtypeCondition.numParam2 = 1
        subtypeCondition.numParam3 = 2
        let subtypeNames: [String] = ["Llanowar Elves", "Arbor Elf", "Elvish Mystic", "Elvish Archdruid"]
        
        let powerCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        powerCondition.type = .powerEqualTo
        powerCondition.numParam1 = 2
        powerCondition.numParam2 = 1
        powerCondition.numParam3 = 3
        let powerNames: [String] = ["Elvish Archdruid", "Alloy Myr"]
        
        let toughnessCondition: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        toughnessCondition.type = .toughnessEqualTo
        toughnessCondition.numParam1 = 1
        toughnessCondition.numParam2 = 2
        toughnessCondition.numParam3 = 3
        let toughnessNames: [String] = ["Arbor Elf", "Elvish Mystic", "Llanowar Elves"]
        
        let landAndElfCondition: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        landAndElfCondition.subconditionList = Set<Subcondition>(arrayLiteral: landCondition, subtypeCondition)
        
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, landNames, landCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, creatureNames, creatureCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, pwNames, pwCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, artifactNames, artifactCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, enchantmentNames, enchantmentCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, instantNames, instantCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, sorceryNames, sorceryCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, nameNames, nameCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, cmcNames, cmcCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, supertypeNames, supertypeCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, subtypeNames, subtypeCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, powerNames, powerCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, toughnessNames, toughnessCondition))
        for _ in 0 ..< TEST_ITER_COUNT{
            elfSimulator.shuffleDeck()
            XCTAssertNoThrow(try elfSimulator.testHandAgainstCondition(handSize: 7, condition: landAndElfCondition))
        }
        
        
        //Test mana-pool checks
        let ratCard: MCard = ratSimulator.cards.first { (card) -> Bool in
            return card.name == "Relentless Rats"
            }!

        var goodPool: ManaPool = ManaPool()
        goodPool.b = 2
        goodPool.w = 1
        
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        goodPool.w -= 1
        goodPool.u += 1
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        goodPool.u -= 1
        goodPool.b += 1
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        goodPool.b -= 1
        goodPool.r += 1
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        goodPool.r -= 1
        goodPool.g += 1
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        goodPool.g -= 1
        goodPool.c += 1
        XCTAssert(goodPool.canCoverCost(ofCard: ratCard))
        
        var badPool: ManaPool = ManaPool()
        badPool.b = 1
        badPool.w = 2
        XCTAssertFalse(badPool.canCoverCost(ofCard: ratCard))
        
        let nayaCard: MCard = nayaSimulator.cards.first { (card) -> Bool in
            return card.name == "Naya Hushblade"
            }!
        
        goodPool = ManaPool()
        
        goodPool.g = 1
        goodPool.w = 1
        XCTAssert(goodPool.canCoverCost(ofCard: nayaCard))
        
        goodPool.w -= 1
        goodPool.r += 1
        XCTAssert(goodPool.canCoverCost(ofCard: nayaCard))
        
        badPool = ManaPool()
        
        badPool.g = 2
        badPool.c = 1
        XCTAssertFalse(badPool.canCoverCost(ofCard: nayaCard))
        
        badPool.g = 0
        badPool.r = 2
        XCTAssertFalse(badPool.canCoverCost(ofCard: nayaCard))
        
        //Mana Pool Business
        
        let shrineCard: MCardLand = nayaSimulator.cards.first { (card) -> Bool in
            return card.name == "Jungle Shrine"
            }! as! MCardLand
        
        XCTAssert(shrineCard.ubYield == -1)
        
        goodPool = ManaPool()
        goodPool.r = 1
        goodPool.w = 1
        goodPool.g = 1
        //print(goodPool.payCost(ofCard: nayaCard))
        
        
        
        //Create "sample hand" for nayaSimulator
        //[Jungle Shrine, Wind-Scarred Crag, Forest, Ghalta, Primal Hunger, Naya Hushblade, Mountain, Mutagenic Growth]
        
        nayaSimulator.cards.swapAt(0, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Jungle Shrine"
            }!)
        nayaSimulator.cards.swapAt(1, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Wind-Scarred Crag"
            }!)
        nayaSimulator.cards.swapAt(2, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Forest"
            }!)
        nayaSimulator.cards.swapAt(3, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Ghalta, Primal Hunger"
            }!)
        nayaSimulator.cards.swapAt(4, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Naya Hushblade"
            }!)
        nayaSimulator.cards.swapAt(5, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Mountain"
            }!)
        nayaSimulator.cards.swapAt(6, nayaSimulator.cards.index { (card) -> Bool in
            card.name == "Selesnya Guildmage"
            }!)
        
        var nayaState: FieldState = FieldState(deck: nayaSimulator.cards, handSize: 7)
        
        XCTAssert(nayaState.allTurnResults().count == 4)//4 possible land plays
        
        XCTAssertNoThrow(nayaState = try nayaState.playCard(name: "Jungle Shrine").first!)
        XCTAssertThrowsError(nayaState = try nayaState.playCard(name: "Wind-Scarred Crag").first!)
        nayaState.advanceTurn()
        XCTAssert(nayaState.allTurnResults().count == 4)//4 possible plays; 2 that land on Naya Hushblade, 1 on Selesnya Guildmage, and 1 with Wind-Scarred Crag out
        
        XCTAssertNoThrow(nayaState = try nayaState.playCard(name: "Wind-Scarred Crag").first!)
        XCTAssert(nayaState.allLandTapCombinations().count == 4)
        nayaState.advanceTurn()
        XCTAssert(nayaState.allTurnResults().count == 9)//9 total plays available
        
        
        XCTAssertNoThrow(nayaState = try nayaState.playCard(name: "Forest").first!)
        XCTAssert(try nayaState.playCard(name: "Selesnya Guildmage").count == 3)//only three land-tap combos can be done to play Selesnya Guildmage
        

        
        

        //Going back to the simulator (which is still set up with that sweet opening hand), test some subconditions
        
        let specificPlayable1: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        specificPlayable1.type = .playable
        specificPlayable1.stringParam1 = "Mountain"
        XCTAssert(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: specificPlayable1))
        
        let specificPlayable2: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        specificPlayable2.type = .playable
        specificPlayable2.stringParam1 = "Ghalta, Primal Hunger"
        XCTAssertFalse(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: specificPlayable2))
        
        let creaturePlayable: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        creaturePlayable.type = .playable
        creaturePlayable.typeParam = .creature
        XCTAssert(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: creaturePlayable))
        
        let creaturePlayable2: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        creaturePlayable2.type = .playableByTurn
        creaturePlayable2.typeParam = .creature
        creaturePlayable2.numParam1 = 2
        
        XCTAssert(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: creaturePlayable2))
        creaturePlayable2.numParam1 = 1
        XCTAssertFalse(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: creaturePlayable2))//can't play either creature on first turn
 
        
        let manaCoverage: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        manaCoverage.type = .manaCoverage
        XCTAssert(try nayaSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: manaCoverage))
        XCTAssert(try nayaSimulator.testHandAgainstSubcondition(handSize: 1, subcondition: manaCoverage))//should also work with JUST Jungle Shrine
        
        let multiCondition: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        multiCondition.subconditionList = Set<Subcondition>([specificPlayable1, creaturePlayable])
        XCTAssert(try nayaSimulator.testHandAgainstCondition(handSize: 7, condition: multiCondition))//yes, you have a playable mountain, and also a playable creature
        let multiCondition2: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        multiCondition2.subconditionList = Set<Subcondition>([specificPlayable2, creaturePlayable])
        XCTAssertFalse(try nayaSimulator.testHandAgainstCondition(handSize: 7, condition: multiCondition2))//no; while you have a playable mountain, you do not have the mana to play Ghalta, Primal Hunger
        
        let nayaKeepRule1: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        nayaKeepRule1.conditionList = Set<Condition>([multiCondition, multiCondition2])
        XCTAssert(try nayaSimulator.testHandAgainstKeepRule(handSize: 7, keeprule: nayaKeepRule1))
        
        
        //MARK: MulliganRuleset shenanigans
        var result1: SimulationResult = SimulationResult()
        let result2: SimulationResult = SimulationResult()
        
        result1.numTrials = 4
        result1.card7Successes = 4
        result2.numTrials = 6
        result2.card6Successes = 3
        result2.card5Successes = 3
        
        result1 += result2
        XCTAssertEqual(result1.numTrials, 10)
        XCTAssertNotEqual(result1.card7Successes, result2.card7Successes)
        XCTAssertEqual(result1.card6Successes, result2.card6Successes)
        
        //Testing the whole shebang
        creaturePlayable2.numParam1 = 2
        
        let condition7: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        condition7.subconditionList = Set<Subcondition>([landCondition, creaturePlayable2])
        let keepRule7: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        keepRule7.conditionList = Set<Condition>([condition7])
        
        let condition61: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        let condition62: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        
        condition61.subconditionList = Set<Subcondition>([manaCoverage])
        condition61.subconditionList = Set<Subcondition>([creaturePlayable])
        let keepRule6: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        keepRule6.conditionList = Set<Condition>([condition61, condition62])
        
        let ruleset1: MulliganRuleset = MulliganRuleset(entity: MulliganRuleset.entityDescription(context: context), insertInto: context)
        ruleset1.keepRule7 = keepRule7
        ruleset1.keepRule6 = keepRule6
        
        
        nayaSimulator.shuffleDeck()
        self.measure{
            let mulliganTestResult: SimulationResult = nayaSimulator.testDeckAgainstMulliganMultiple(ruleset: ruleset1, repetitions: 1000)
            print("\(mulliganTestResult)")
        }

    }//testDecks
    
    fileprivate func testTotalsCondition(_ elfSimulator: Simulator, _ myHand: inout [MCard], _ successNames: [String], _ testSubcondition: Subcondition) throws {
        var count: Int = 0
        var conditionResult: Bool = false
        
        for _ in 0 ..< TEST_ITER_COUNT{
            elfSimulator.shuffleDeck()
            
            XCTAssertNoThrow(try myHand = elfSimulator.pullOutHand(fromIndex: 0, toIndex: 6))
            count = myHand.filter { (card) -> Bool in
                return successNames.contains(card.name)
                }.count
            
            XCTAssertNoThrow(conditionResult = try elfSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: testSubcondition))
            if count >= testSubcondition.numParam2 && count <= testSubcondition.numParam3{
                if !conditionResult{
                    print("Success names: \(successNames), hand: \(myHand)")
                }
                XCTAssertTrue(conditionResult)
            }
            else{
                XCTAssertFalse(conditionResult)
            }
        }
    }
    
}//MTGDeckerTests










