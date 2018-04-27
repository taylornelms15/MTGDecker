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
    
    public static var LAND_DEFAULT_NAME = "Default - Land Total"
    public static var PLAYABLE_DEFAULT_NAME = "Default - Playable"
    
    
    /**
     Variable used to evaluate the resource-intensity of testing the given rule. A value of 1.0 will not modify the number of trials done while simulating a deck. Lower values decrease the number of trials done to test hands against a rule.
     Functions by scaling the keep rules' performanceRatio and combining them, to get an arbitrarily weighted average attempting to approximate the performance effect running each one will have.
     */
    public var performanceRatio: Double{
        
        let scaled7: Double = (keepRule7?.performanceRatio ?? 1.0) * 0.7
        let scaled6: Double = (keepRule6?.performanceRatio ?? 1.0) * 0.2
        let scaled5: Double = (keepRule5?.performanceRatio ?? 1.0) * 0.075
        let scaled4: Double = (keepRule4?.performanceRatio ?? 1.0) * 0.025

        let result: Double = scaled7 + scaled6 + scaled5 + scaled4
        
        return result
    }//performanceRatio
    
    
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
    
    static func makePlayableDefault(_ context: NSManagedObjectContext) -> MulliganRuleset{
        
        //Make the objects
        
        let playableRuleset: MulliganRuleset = MulliganRuleset(entity: MulliganRuleset.entityDescription(context: context), insertInto: context)
        
        let keepRule7: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule6: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule5: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        let keepRule4: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
        
        let playableCondition7: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        let playableCondition6: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        let playableCondition5: Condition = Condition(entity: Condition.entityDescription(context: context), insertInto: context)
        
        let playableSubcondition7: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let playableSubcondition6: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let playableSubcondition5: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let landSubcondition7: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let landSubcondition6: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        let landSubcondition5: Subcondition = Subcondition(entity: Subcondition.entityDescription(context: context), insertInto: context)
        
        //Modify the conditions
        
        playableSubcondition7.type = .playableByTurn
        playableSubcondition7.typeParam = .creature
        playableSubcondition7.numParam1 = 3
        
        landSubcondition7.type = .landTotal
        landSubcondition7.numParam2 = 1
        landSubcondition7.numParam3 = 6
        
        playableSubcondition6.type = .playable
        playableSubcondition6.typeParam = .nonland
        
        landSubcondition6.type = .landTotal
        landSubcondition6.numParam2 = 1
        landSubcondition6.numParam3 = 5
        
        playableSubcondition5.type = .playable
        playableSubcondition5.typeParam = .nonland
        
        landSubcondition5.type = .landTotal
        landSubcondition5.numParam2 = 1
        landSubcondition5.numParam3 = 4
        
        //Connect the conditions upwards
        
        playableCondition7.subconditionList = Set<Subcondition>([playableSubcondition7, landSubcondition7])
        playableCondition6.subconditionList = Set<Subcondition>([playableSubcondition6, landSubcondition6])
        playableCondition5.subconditionList = Set<Subcondition>([playableSubcondition5, landSubcondition5])
        
        keepRule7.conditionList = Set<Condition>([playableCondition7])
        keepRule7.handSize = 7
        keepRule6.conditionList = Set<Condition>([playableCondition6])
        keepRule6.handSize = 6
        keepRule5.conditionList = Set<Condition>([playableCondition5])
        keepRule5.handSize = 5
        keepRule4.handSize = 4
        
        playableRuleset.keepRule7 = keepRule7
        playableRuleset.keepRule6 = keepRule6
        playableRuleset.keepRule5 = keepRule5
        playableRuleset.keepRule4 = keepRule4
        
        playableRuleset.name = MulliganRuleset.PLAYABLE_DEFAULT_NAME
        playableRuleset.isDefault = true
        
        return playableRuleset
    }//makeLandDefault
    
}//MulliganRuleset
