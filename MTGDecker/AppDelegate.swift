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
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Put initial card names and set sources in
        let context: NSManagedObjectContext = self.persistentContainer.viewContext
        initPlayerList(context)
        initCardNameList(context)
        _ = mulliganDefaults(context)
        
        
        return true
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
        
        if results.count == 0{
            myMulliganDefaults.insert(MulliganRuleset.makeLandDefault(context))
            
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

