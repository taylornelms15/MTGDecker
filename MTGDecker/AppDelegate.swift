//
//  AppDelegate.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/23/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import UIKit
import CoreData

///Default player id
var DEFAULT_PLAYER_ID: Int64 = Int64(1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var restrictRotation:TypeInterfaceOrientationMask = .all
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Put initial card names and set sources in
        let context: NSManagedObjectContext = self.persistentContainer.viewContext
        initPlayerList(context)
        initCardNameList(context)
        _ = mulliganDefaults(context)
        _ = successDefaults(context)
        _ = basicLandDefaults(context)
        
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        switch self.restrictRotation {
        case .all:
            return UIInterfaceOrientationMask.all
        case .portrait:
            return UIInterfaceOrientationMask.portrait
        case .landscape:
            return UIInterfaceOrientationMask.landscape
        }
    }
    
    fileprivate func initPlayerList(_ context: NSManagedObjectContext){
        
        let playerFR: NSFetchRequest<Player> = Player.fetchRequest()
        var results: [Player] = []
        do{
            results = try context.fetch(playerFR)
        }
        catch{
            NSLog("Error fetching player list from core data: \(error)")
        }
        
        if results.count == 0{
            let newPlayer: Player = Player(context: context)
            newPlayer.id = DEFAULT_PLAYER_ID
            newPlayer.name = "Player 1"
            
            do{
                try context.save()
            }
            catch{
                NSLog("Error saving player to core data: \(error)")
            }
        }//if no player
        

        
    }//initPlayerList
    
    private func getCurrentPlayer(_ context: NSManagedObjectContext) -> Player{
        let playerFR: NSFetchRequest<Player> = Player.fetchRequest()
        var results: [Player] = []
        do{
            results = try context.fetch(playerFR)
        }
        catch{
            NSLog("Error fetching player list from core data: \(error)")
        }
        
        //TODO: expand functionality to allow for multiple players
        results.sort { (player1, player2) -> Bool in
            return player1.id < player2.id
        }//sorts players by id, so can get the smallest one
        
        return results[0]
        
    }//getCurrentPlayer
    
    fileprivate func initCardNameList(_ context: NSManagedObjectContext) {
        let cnlFR: NSFetchRequest<CardNameList> = CardNameList.fetchRequest()
        
        var results: [CardNameList] = []
        
        do {
            results = try context.fetch(cnlFR)
        } catch {
            print("Failed")
        }
        
        var myCardNameList: CardNameList;
        
        if results.count == 0{
            myCardNameList = CardNameList(context: context)
            myCardNameList.sourceSetCodes = Set<String>()
            myCardNameList.cardNames = [];
            
            myCardNameList.initiateFromFiles()
            
            do{
                try context.save()
            }
            catch {
                NSLog("\(error)")
            }
        }
        else{
            myCardNameList = results[0];
            
        }//else
        
        DispatchQueue.global(qos: .utility).async{
            myCardNameList.updateCardNames(context: context)
        }
    }
    
    func mulliganDefaults(_ context: NSManagedObjectContext) -> Set<MulliganRuleset>{
        let mulFR: NSFetchRequest<MulliganRuleset> = MulliganRuleset.fetchRequest()
        mulFR.predicate = NSPredicate(format: "isDefault = true")
        
        var results: [MulliganRuleset] = []
        
        do {
            results = try context.fetch(mulFR)
        } catch {
            NSLog("Problem finding default mulligan rulesets: \(error)")
        }
        
        var myMulliganDefaults: Set<MulliganRuleset> = Set<MulliganRuleset>()
        
        if results.count < MulliganRuleset.DEFAULT_NAMES.count{
            myMulliganDefaults.insert(MulliganRuleset.makeLandDefault(context))
            myMulliganDefaults.insert(MulliganRuleset.makePlayableDefault(context))
            
            do{
                try context.save()
            }//do
            catch{
                NSLog("Error saving fetchrequest to core data: \(error)")
            }//catch

        }//if making fresh defaults
        else{
            for result in results{
                myMulliganDefaults.insert(result)
            }//for
        }//if just finding the defaults

        return myMulliganDefaults
        
    }//initMulliganDefaults
    
    func successDefaults(_ context: NSManagedObjectContext) -> Set<SuccessRule>{
        let sucFR: NSFetchRequest<SuccessRule> = SuccessRule.fetchRequest()
        sucFR.predicate = NSPredicate(format: "isDefault = true")
        
        var results: [SuccessRule] = []
        
        do {
            results = try context.fetch(sucFR)
        } catch {
            NSLog("Problem finding default success rule rulesets: \(error)")
        }
        
        var mySuccessRuleDefaults: Set<SuccessRule> = Set<SuccessRule>()
        
        if results.count < SuccessRule.DEFAULT_NAMES.count{
            mySuccessRuleDefaults.insert(SuccessRule.makePlayableDefault(context))
            
            do{
                try context.save()
            }//do
            catch{
                NSLog("Error saving fetchrequest to core data: \(error)")
            }//catch
            
        }//if making fresh defaults
        else{
            for result in results{
                mySuccessRuleDefaults.insert(result)
            }//for
        }//if just finding the defaults
        
        return mySuccessRuleDefaults
        
    }//initSuccessDefaults
    
    func basicLandDefaults(_ context: NSManagedObjectContext) -> Set<MCard>{
        var landDeck: Deck? = nil
        var landBuilder: DeckBuilder? = nil
        
        let landFR: NSFetchRequest<MCard> = MCard.fetchRequest()
        landFR.predicate = NSPredicate(format: "name = %@ OR name = %@ OR name = %@ OR name = %@ OR name = %@ OR name = %@", "Plains", "Island", "Swamp", "Mountain", "Forest", "Wastes")
        
        var results: [MCard] = []
        
        do {
            results = try context.fetch(landFR)
        } catch {
            NSLog("Problem finding default basic lands: \(error)")
        }
        
        if results.count != MCard.BASIC_LAND_DEFAULTS.count{
            landDeck = Deck(entity: Deck.entityDescription(context: context), insertInto: context)
            landBuilder = DeckBuilder(inContext: context, deck: landDeck!)
        }//if we have fewer than 6 results
        else{
            print("Have all relevant land defaults")
        }
        
        for entry in MCard.BASIC_LAND_DEFAULTS{
            if !results.contains(where: { (card) -> Bool in
                return card.name == entry.key
            }){
                
                self.addLandByMultiverseId(name: entry.key, id: entry.value, using: landBuilder!)
                
                context.performAndWait {
                    do{
                        try context.save()
                    }catch{
                        NSLog("Error saving a basic land (\(entry.key)) into the Defaults deck: \(error)")
                    }
                }
                
            }//if we don't have that card
        }//for each entry in the dictionary
        
        
        
        
        return Set<MCard>()
    }//basicLandDefaults
    
    func addLandByMultiverseId(name: String, id: Int, using builder: DeckBuilder){
    
        builder.addCardByName(name, with: id)
        
        print("Added default \(name)")
        
    }//addLandByMultiverseId

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MTGDecker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
enum TypeInterfaceOrientationMask {
    case all
    case portrait
    case landscape
}

