//
//  Condition+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class Condition: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Condition> {
        return NSFetchRequest<Condition>(entityName: "Condition")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var inv_keeprule: Set<KeepRule>?
    @NSManaged public var inv_successrule: Set<SuccessRule>?
    @NSManaged public var subconditionList: Set<Subcondition>?

    static public func == (lhs: Condition, rhs: Condition) -> Bool{
        return lhs.subconditionList == rhs.subconditionList
    }//isEqual
    
    public func summary()->String{
        
        if subconditionList == nil || subconditionList!.count == 0{
            return "Accepts all cards"
        }//if no subconditions
        
        if subconditionList!.count == 1{
            return subconditionList!.first!.summary()
        }//if only one subcondition
        else{
            let orderedMembers: [Subcondition] = Array<Subcondition>(subconditionList!)
            var resultString = ""
            
            for i in 0 ..< orderedMembers.count - 1{
                resultString.append("(")
                resultString.append(orderedMembers[i].summary())
                resultString.append(") AND ")
            }//for all but the last string
            resultString.append("(")
            resultString.append(orderedMembers.last!.summary())
            resultString.append(")")
            
            return resultString
            
        }//if more than one subcondition
        
    }//summary
    
    /**
     Variable used to evaluate the resource-intensity of testing the given condition. A value of 1.0 will not modify the number of trials done while simulating a deck. Lower values decrease the number of trials done to test hands against a condition.
     */
    public var performanceRatio: Double{
        
        var result: Double = 1.0
        
        for subcon in subconditionList ?? Set<Subcondition>(){
            result *= subcon.performanceRatio //since we have to AND the subconditions, make the number-of-trials reduction cumulative
        }
        
        return result
    }//performanceRatio
    
}//Condition

