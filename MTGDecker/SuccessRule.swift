//
//  SuccessRule+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class SuccessRule: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SuccessRule> {
        return NSFetchRequest<SuccessRule>(entityName: "SuccessRule")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged private var conditions: NSSet?
    @NSManaged public var inv_deck: Deck?
    @NSManaged public var inv_deck_active: Deck?
    
    public var conditionList: Set<Condition>?{
        get{
            return self.conditions as? Set<Condition>
        }
        set{
            conditions = newValue as NSSet?
        }
    }//conditionList
    
}//SuccessRule
