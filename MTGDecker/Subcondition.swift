//
//  Subcondition+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData


public class Subcondition: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subcondition> {
        return NSFetchRequest<Subcondition>(entityName: "Subcondition")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    ///Represents the type of subcondition. See `type`
    @NSManaged private var condType: Int16
    ///An "equal to" given value
    @NSManaged public var numParam1: Int16
    ///A "greater than or equal to" given value
    @NSManaged public var numParam2: Int16
    ///A "less than or equal to" given value
    @NSManaged public var numParam3: Int16
    ///A "color inclusion" given value. Note: should primarily be modified by class methods.
    @NSManaged public var numParam4: Int16
    ///reserved
    @NSManaged public var numParam5: Int16
    ///An "equal to" given value for a string parameter
    @NSManaged public var stringParam1: String?
    ///reserved
    @NSManaged public var stringParam2: String?
    ///A "type" given value. See `typeParam`
    @NSManaged private var stringParam3: String?
    @NSManaged public var inv_condition: Condition?

    ///Variable encapsulating the type of the subcondition.
    public var type: ConditionType{
        get{
            return ConditionType(rawValue: condType)!
        }
        set{
            condType = newValue.rawValue
        }
    }//type
    
    ///Variable encapsulating a "card type" parameter. Wraps the `@NSManaged` parameter `stringParam3`
    public var typeParam: CardType{
        get{
            return CardType(rawValue: stringParam3 ?? "none")!
        }
        set{
            stringParam3 = newValue.rawValue
        }
    }//typeParam
    
    /**
     An enumeration detaining the different type of available subcondition variants.
     */
    public enum ConditionType: Int16{
        ///Checks for number of lands matching a given total
        case landTotal
        ///Checks for number of creature cards matching a given total
        case creatureTotal
        ///Checks for number of planeswalker cards matching a given range
        case planeswalkerTotal
        ///Checks for number of artifact cards matching a given total
        case artifactTotal
        ///Checks for number of enchantment cards matching a given total
        case enchantmentTotal
        ///Checks for number of instant cards matching a given total
        case instantTotal
        ///Checks for number of sorcery cards matching a given total
        case sorceryTotal
        
        ///Checks for a card with a given name
        case nameEqualTo
        ///Checks for a card whose CMC is equal to a given value
        case cmcEqualTo
        ///Checks for a card with a given subtype
        case subtypeEqualTo
        ///Checks for a card with a given supertype
        case supertypeEqualTo
        ///Checks for a card with a given power
        case powerEqualTo
        ///Checks for a card with a given toughness
        case toughnessEqualTo
        
        ///Checks if there is a card playable with hand makeup. Accepts specific-card namings, or "card is of category." Limited in execution to "at least one card in hand is playable"
        case playable
        ///Checks if there is a card playable by given turn
        case playableByTurn
        ///Checks if lands cover mana spread
        case manaCoverage
        ///Checks for number of reactive cards matching a given total
        case reactiveTotal

    }//conditionType
    
    ///Used to dictate card types for broad categories, such as playability
    public enum CardType: String{
        ///No type
        case none = "none"
        ///Land type
        case land = "l"
        ///Creature type
        case creature = "c"
        ///Planeswalker type
        case planeswalker = "pw"
        ///Artifact type
        case artifact = "a"
        ///Enchantment type
        case enchantment = "e"
        ///Instant type
        case instant = "i"
        ///Sorcery type
        case sorcery = "s"
        ///Non-land type
        case nonland = "nl"
    }//CardType
    
    /**
     Enum defining values for bitmasks for checking colors against a given "color inclusion" value
     */
    public enum ColorMask: Int16{
        case wMask = 0x0001
        case uMask = 0x0002
        case bMask = 0x0004
        case rMask = 0x0008
        case gMask = 0x0010
        case cMask = 0x0020
        case anyMask = 0x0040
    }
    
    
}//Subcondition
