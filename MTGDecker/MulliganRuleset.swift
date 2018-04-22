//
//  MulliganRuleset+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class MulliganRuleset: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MulliganRuleset> {
        return NSFetchRequest<MulliganRuleset>(entityName: "MulliganRuleset")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var inv_player: NSSet?
    @NSManaged public var inv_player_active: NSSet?
    @NSManaged public var keepRule4: KeepRule?
    @NSManaged public var keepRule5: KeepRule?
    @NSManaged public var keepRule6: KeepRule?
    @NSManaged public var keepRule7: KeepRule?
    
    //MARK: Default Constructors
    
    public static var LAND_DEFAULT_NAME = "Default Land-Total Mulligan"
    
    static func makeLandDefault(_ context: NSManagedObjectContext) -> MulliganRuleset{
        
        //Make the objects
        
        let landRuleset: MulliganRuleset = MulliganRuleset(entity: MulliganRuleset.entityDescription(context: context), insertInto: context)
        
        let keepRule7: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule6: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule5: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule4: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        
        let landCondition7: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        let landCondition6: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        let landCondition5: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        
        let landSubcondition7: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let landSubcondition6: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let landSubcondition5: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        
        //Modify the conditions
        
        landSubcondition7.type = .landTotal
        landSubcondition7.numParam2 = 2
        landSubcondition7.numParam3 = 5
        
        landSubcondition6.type = .landTotal
        landSubcondition6.numParam2 = 2
        landSubcondition6.numParam3 = 4
        
        landSubcondition5.type = .landTotal
        landSubcondition5.numParam2 = 1
        landSubcondition5.numParam3 = 4
        
        //Connect the conditions upwards
        
        landCondition7.subconditionList = Set<Subcondition>([landSubcondition7])
        landCondition6.subconditionList = Set<Subcondition>([landSubcondition6])
        landCondition5.subconditionList = Set<Subcondition>([landSubcondition5])
        
        keepRule7.conditionList = Set<Condition>([landCondition7])
        keepRule7.handSize = 7
        keepRule6.conditionList = Set<Condition>([landCondition6])
        keepRule6.handSize = 6
        keepRule5.conditionList = Set<Condition>([landCondition5])
        keepRule5.handSize = 5
        keepRule4.handSize = 4
        
        landRuleset.keepRule7 = keepRule7
        landRuleset.keepRule6 = keepRule6
        landRuleset.keepRule5 = keepRule5
        landRuleset.keepRule4 = keepRule4
        
        landRuleset.name = MulliganRuleset.LAND_DEFAULT_NAME
        landRuleset.isDefault = true
        
        return landRuleset
    }//makeLandDefault
    
}//MulliganRuleset
