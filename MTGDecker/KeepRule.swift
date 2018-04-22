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
    @NSManaged public var handSize: Int16
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

    /**
     Produces a human-readable summary of the rule. Ends up displayed as detail text in a table.
     */
    public func summary()->String{
        if conditionList == nil || conditionList!.count == 0{
            return "Accepts all cards"
        }//if no subconditions
        
        if conditionList!.count == 1{
            if conditionList!.first!.summary() == "Accepts all cards"{
                return "Accepts all cards"
            }//if accepting all cards
            else{
                return "Keep if: \(conditionList!.first!.summary())"
            }
        }//if only one subcondition
        else{
            let orderedMembers: [Condition] = Array<Condition>(conditionList!)
            var resultString = "Keep if: "
            
            for i in 0 ..< orderedMembers.count - 1{
                resultString.append("(")
                resultString.append(orderedMembers[i].summary())
                resultString.append(") OR")
            }//for all but the last string
            resultString.append("(")
            resultString.append(orderedMembers.last!.summary())
            resultString.append(")")
            
            return resultString
            
        }//if more than one subcondition
    }//summary
    
    
}//KeepRule
