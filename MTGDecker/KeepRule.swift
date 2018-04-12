//
//  KeepRule+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class KeepRule: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeepRule> {
        return NSFetchRequest<KeepRule>(entityName: "KeepRule")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged private var conditions: NSSet?
    @NSManaged public var inv_mulliganruleset4: MulliganRuleset?
    @NSManaged public var inv_mulliganruleset5: NSSet?
    @NSManaged public var inv_mulliganruleset6: NSSet?
    @NSManaged public var inv_mulliganruleset7: NSSet?
    
    public var conditionList: Set<Condition>?{
        get{
            return self.conditions as? Set<Condition>
        }
        set{
            conditions = newValue as NSSet?
        }
    }//conditionList
}//KeepRule
