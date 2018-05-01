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
        ///Checks for number of lands matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case landTotal
        ///Checks for number of creature cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case creatureTotal
        ///Checks for number of planeswalker cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case planeswalkerTotal
        ///Checks for number of artifact cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case artifactTotal
        ///Checks for number of enchantment cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case enchantmentTotal
        ///Checks for number of instant cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case instantTotal
        ///Checks for number of sorcery cards matching a given total (`numParam2 ≤ x ≤ numParam3`)
        case sorceryTotal
        
        ///Checks for a card with a given name (`stringParam1`)
        case nameEqualTo
        ///Checks for a card whose CMC is equal to a given value (`numParam1`)
        case cmcEqualTo
        ///Checks for a card with a given subtype (`stringParam1`)
        case subtypeEqualTo
        ///Checks for a card with a given supertype (`stringParam1`)
        case supertypeEqualTo
        ///Checks for a card with a given power (`numParam1`)
        case powerEqualTo
        ///Checks for a card with a given toughness (`numParam1`)
        case toughnessEqualTo
        
        ///Checks if there is a card playable with the current hand makeup. Requires `typeParam` to be set to a given category. Limited in execution to "at least one card in hand is playable"
        case playable
        ///Checks if there is a card playable by given turn (`numParam1`) with the current hand makeup. Requires `typeParam` to be set to a given category. Limited in execution to "at least one card in hand is playable"
        case playableByTurn
        ///Checks if lands cover mana spread
        case manaCoverage
        ///Checks for number of reactive cards matching a given total (`numParam1`)
        case reactiveTotal
        ///Not-yet-defined
        case undefinedTotal

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
    
    public func summary()-> String{
        switch(self.type){
        case .landTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no lands"}
                return "\(numParam2) land\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) lands" }
        case .creatureTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no creatures"}
                return "\(numParam2) creature\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) creatures" }
        case .planeswalkerTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no planeswalkers"}
                return "\(numParam2) planeswalker\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) planeswalkers" }
        case .artifactTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no artifacts"}
                return "\(numParam2) artifact\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) artifacts" }
        case .enchantmentTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no enchantments"}
                return "\(numParam2) enchantment\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) enchantments" }
        case .instantTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no instants"}
                return "\(numParam2) instant\((numParam2 == 1) ? "" : "s")" }
            else{ return "between \(numParam2) and \(numParam3) instants" }
        case .sorceryTotal:
            if numParam2 == numParam3{
                if (numParam2 == 0 ){return "no sorceries"}
                return "\(numParam2) sorcer\((numParam2 == 1) ? "y" : "ies")" }
            else{ return "between \(numParam2) and \(numParam3) sorceries" }
            
        case .nameEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) \(numParam2 == 1 ? "copy" : "copies") of \(stringParam1 == nil ? "given card" : stringParam1!)"
            }
            return "contains \(stringParam1 ?? "card of given name")"
        case .cmcEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) card\(numParam2 == 1 ? "" : "s") with \(numParam1 == -1 ? "given CMC" : "CMC \(numParam1)")"
            }
            return "between \(numParam2) and \(numParam3) \(numParam1 == -1 ? "cards with given CMC" : "CMC-\(numParam1) cards")"
        case .subtypeEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) \(stringParam1 ?? "given-subtype") card\(numParam2 == 1 ? "" : "s")"
            }
            return "between \(numParam2) and \(numParam3) \(stringParam1 == nil ? "cards of given subtype" : stringParam1! + " cards")"
        case .supertypeEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) \(stringParam1 ?? "given-supertype") card\(numParam2 == 1 ? "" : "s")"
            }
            return "between \(numParam2) and \(numParam3) \(stringParam1 == nil ? "cards of given supertype" : stringParam1! + " cards")"
        case .powerEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) card\(numParam2 == 1 ? "" : "s") with \(numParam1 == -1 ? "given power" : "power \(numParam1)")"
            }
            return "between \(numParam2) and \(numParam3) \(numParam1 == -1 ? "cards of given power" : "\(numParam1)-power cards")"
        case .toughnessEqualTo:
            if (numParam2 == numParam3){
                return "\(numParam2) card\(numParam2 == 1 ? "" : "s") with \(numParam1 == -1 ? "given toughness" : "toughness \(numParam1)")"
            }
            return "between \(numParam2) and \(numParam3) \(numParam1 == -1 ? "cards of given toughness" : "\(numParam1)-toughness cards")"
            
        case .playable:
            switch typeParam{
            case .land:
                return "playable land"
            case .creature:
                return "playable creature"
            case .planeswalker:
                return "playable planeswalker"
            case .artifact:
                return "playable artifact"
            case .enchantment:
                return "playable enchantment"
            case .instant:
                return "playable instant"
            case .sorcery:
                return "playable sorcery"
            case .nonland:
                return "playable non-land"
            default:
                return ""
            }
        case .playableByTurn:
            switch typeParam{
            case .land:
                return "land playable by turn \(numParam1)"
            case .creature:
                return "creature playable by turn \(numParam1)"
            case .planeswalker:
                return "planeswalker playable by turn \(numParam1)"
            case .artifact:
                return "artifact playable by turn \(numParam1)"
            case .enchantment:
                return "enchantment playable by turn \(numParam1)"
            case .instant:
                return "instant playable by turn \(numParam1)"
            case .sorcery:
                return "sorcery playable by turn \(numParam1)"
            case .nonland:
                return "non-land playable by turn \(numParam1)"
            default:
                return ""
            }
        case .manaCoverage:
            return "land covers mana base"
        case .reactiveTotal:
            return "has \(numParam1) reactive play\(numParam1 == 1 ? "" : "s")"
        case .undefinedTotal:
            if (numParam2 == numParam3){
                return "\(numParam2) \(stringParam1 ?? "given-property") card\(numParam2 == 1 ? "" : "s")"
            }
            return "between \(numParam2) and \(numParam3) \(stringParam1 == nil ? "cards of given property" : stringParam1! + " cards")"
        }//switch
    }//summary
    
    ///Defines equality between two subconditions
    static public func == (lhs: Subcondition, rhs: Subcondition) -> Bool{
        return lhs.type == rhs.type && lhs.typeParam == rhs.typeParam && lhs.numParam1 == rhs.numParam1 && lhs.numParam2 == rhs.numParam2 && lhs.numParam3 == rhs.numParam3 && lhs.numParam4 == rhs.numParam4 && lhs.numParam5 == rhs.numParam5 && lhs.stringParam1 == rhs.stringParam1 && lhs.stringParam2 == rhs.stringParam2 && lhs.stringParam3 == rhs.stringParam3
        
        
    }//isEqual
    
    /**
     Variable used to evaluate the resource-intensity of testing the given subcondition. A value of 1.0 will not modify the number of trials done while simulating a deck. Lower values decrease the number of trials done to test hands against a subcondition.
     */
    public var performanceRatio: Double{
        switch self.type{
        case .playableByTurn:
            if numParam1 <= 2{ return 0.2 }//less performance effect for a smaller number of tested turns
            return 0.13
        case .playable:
            return 0.5
        case .manaCoverage:
            return 0.9
        default:
            return 1.0
        }
    }//performanceRatio
    
    /**
     Enum defining values for bitmasks for checking colors against a given "color inclusion" value. Likely not needed.
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
