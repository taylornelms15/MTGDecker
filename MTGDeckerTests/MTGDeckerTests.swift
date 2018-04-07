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
        let elfNames: [String] = ["Forest", "Llanowar Elves", "Elvish Mystic", "Arbor Elf", "Elvish Archdruid", "Elvish Visionary", "Traveler\'s Amulet", "Bloom Tender", "Cultivator\'s Caravan", "Alloy Myr"]
        
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
        
        ratDeck!.changeCardQuantity(ofCardNamed: "Swamp", toQuantity: 24, context: context)
        ratDeck!.changeCardQuantity(ofCardNamed: "Relentless Rats", toQuantity: 36, context: context)
        
        
        for elfName in elfNames{
            elfDeck!.changeCardQuantity(ofCardNamed: elfName, toQuantity: 4, context: context)
        }
        elfDeck!.changeCardQuantity(ofCardNamed: "Forest", toQuantity: 24, context: context)
        
        
        
    }//setUp
    
    func weHaveCardsNow(cardName: String){
        //print("Leaving group with card \(cardName)")
        cardAddGroup.leave()
    
    }//weHaveCardsNow
    func weHavePicsNow(card: MCard){
        //print("Leaving group with pic for \(card.name)")
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

        print("Rat deck: \(ratDeck!.cardRecord)")
        print("Elf deck: \(elfDeck!.cardRecord)")
        
        
        XCTAssert(true)
    }
    
}
