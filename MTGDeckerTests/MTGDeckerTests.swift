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

class MTGDeckerTests: XCTestCase {
    
    let magic: Magic = Magic();
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! MTGDecker.AppDelegate).persistentContainer.viewContext
    let cardAddGroup: DispatchGroup = DispatchGroup()
    var ratDeck: Deck? = nil
    var elfDeck: Deck? = nil
    
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
        
        NotificationCenter.default.addObserver(forName: .cardAddNotification, object: nil, queue: nil) { (notification) in
            self.weHaveCardsNow(cardName: (notification.object as! String))
        }
        NotificationCenter.default.addObserver(forName: .cardImageAddNotification, object: nil, queue: nil) { (notification) in
            self.weHavePicsNow(card: (notification.object as! MCard))
        }
        
        
        let ratNames: [String] = ["Swamp", "Relentless Rats"]
        let elfNames: [String] = ["Forest", "Llanowar Elves", "Elvish Mystic", "Arbor Elf", "Elvish Archdruid", "New Horizons", "Traveler\'s Amulet", "Naturalize", "Cultivator\'s Caravan", "Alloy Myr", "Nissa Revane"]
        
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
        let creatureNames: [String] = ["Llanowar Elves", "Elvish Mystic", "Arbor Elf", "Elvish Archdruid", "Alloy Myr"]//The only land in the whole bunch
        
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, landNames, landCondition))
        XCTAssertNoThrow(try testTotalsCondition(elfSimulator, &myHand, creatureNames, creatureCondition))
        

    }//testDecks
    
    fileprivate func testTotalsCondition(_ elfSimulator: Simulator, _ myHand: inout [MCard], _ successNames: [String], _ testSubcondition: Subcondition) throws {
        var count: Int = 0
        var conditionResult: Bool = false
        
        for _ in 0 ..< 500{
            elfSimulator.shuffleDeck()
            
            XCTAssertNoThrow(try myHand = elfSimulator.pullOutHand(fromIndex: 0, toIndex: 6))
            count = myHand.filter { (card) -> Bool in
                return successNames.contains(card.name)
                }.count
            
            XCTAssertNoThrow(conditionResult = try elfSimulator.testHandAgainstSubcondition(handSize: 7, subcondition: testSubcondition))
            if count >= testSubcondition.numParam2 && count <= testSubcondition.numParam3{
                XCTAssertTrue(conditionResult)
            }
            else{
                XCTAssertFalse(conditionResult)
            }
        }
    }
    
}//MTGDeckerTests










