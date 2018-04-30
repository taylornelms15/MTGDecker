//
//  Player+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class Player: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var activeDeck: Deck?
    @NSManaged private var decks: NSSet?
    @NSManaged private var mulliganRulesets: NSSet?
    
    var deckList: Set<Deck>?{
        get{
            return self.decks as! Set<Deck>?
        }
        set{
            if (newValue == nil){
                decks = nil
            }
            else{
                decks = NSSet(set: newValue!)
            }
        }
    }//deckList

}//Player
