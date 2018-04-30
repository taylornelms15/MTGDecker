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
    
    public static func == (lhs: SuccessRule, rhs: SuccessRule) -> Bool{
        return lhs.conditionList == rhs.conditionList
    }//isEqual
    
    /**
     Produces a human-readable summary of the rule. Ends up displayed as detail text in a table.
     */
    public func summary()->String{
        if conditionList == nil || conditionList!.count == 0{
            return "Always Succeeds"
        }//if no subconditions
        
        if conditionList!.count == 1{
            if conditionList!.first!.summary() == "Accepts all cards"{
                return "Always Succeeds"
            }//if accepting all cards
            else{
                return "Succeeds if: \(conditionList!.first!.summary())"
            }
        }//if only one subcondition
        else{
            let orderedMembers: [Condition] = Array<Condition>(conditionList!)
            var resultString = "Succeeds if: "
            
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
    
    /**
     Variable used to evaluate the resource-intensity of testing the given rule. A value of 1.0 will not modify the number of trials done while simulating a deck. Lower values decrease the number of trials done to test hands against a rule.
     */
    public var performanceRatio: Double{
        
        if conditionList == nil || conditionList!.count == 0{
            return 1.0
        }
        
        var result: Double = 0.0
        var i: Int = 0
        
        for cond in conditionList ?? Set<Condition>(){
            i += 1
            result += cond.performanceRatio
        }
        
        result /= Double(i)
        
        //Average together the performance effects of the separate conditions, because they are OR'd together. This may take some tweaking.
        
        return result
    }//performanceRatio
    
    static func makeSoftSuccess(_ success: SuccessRule) -> [[Softcondition]]{
        var newSoftrule: [[Softcondition]] = []
        for cond in success.conditionList ?? []{
            var condArray: [Softcondition] = []
            for subcond in cond.subconditionList ?? []{
                let newSoftcon = Softcondition(from: subcond)
                condArray.append(newSoftcon)
            }//for each subcondition
            newSoftrule.append(condArray)
        }//for
        
        return newSoftrule
    }//makeSoftSuccess
    
}//SuccessRule
