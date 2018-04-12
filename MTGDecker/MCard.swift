//
//  MCard+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData
import MTGSDKSwift


public class MCard: NSManagedObject, Comparable {

    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MCard> {
        return NSFetchRequest<MCard>(entityName: "MCard")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    public static let typePriorityArray: [String] =     ["Land", "Planeswalker", "Creature", "Artifact", "Enchantment", "Instant", "Sorcery"]
    public static let typeSortArray: [String] =         ["Planeswalker", "Creature", "Enchantment", "Artifact", "Sorcery", "Instant", "Land"]
    public static let typeSortDict: [String: Int] =     ["Planeswalker" : 0,
                                                         "Creature" : 1,
                                                         "Enchantment" : 2,
                                                         "Artifact" : 3,
                                                         "Sorcery" : 4,
                                                         "Instant" : 5,
                                                         "Land" : 6]
    
    @NSManaged public var cmc: Int16
    @NSManaged public var flavor: String?
    @NSManaged public var id: String
    @NSManaged public var isBlack: Bool
    @NSManaged public var isBlue: Bool
    @NSManaged public var isColorless: Bool
    @NSManaged public var isGreen: Bool
    @NSManaged public var isRed: Bool
    @NSManaged public var isWhite: Bool
    @NSManaged public var multiverseId: Int64
    @NSManaged public var name: String
    @NSManaged public var number: String?
    @NSManaged public var power: String?
    @NSManaged public var rarity: String?
    @NSManaged public var setCode: String?
    @NSManaged public var subtypes: [String]?
    @NSManaged public var supertypes: [String]?
    @NSManaged public var text: String?
    @NSManaged public var toughness: String?
    @NSManaged public var types: [String]?
    @NSManaged public var inv_deck: NSSet?
    @NSManaged public var imageURL: String?
    @NSManaged public var image: MCardImage?
    
    //Mana Cost Variables
    @NSManaged public var whiteCost: Int16
    @NSManaged public var blueCost: Int16
    @NSManaged public var blackCost: Int16
    @NSManaged public var redCost: Int16
    @NSManaged public var greenCost: Int16
    @NSManaged public var colorlessCost: Int16//Example: Endbringer
    @NSManaged public var anymanaCost: Int16
    @NSManaged public var xmanaCost: Int16
    @NSManaged public var whiteblueCost: Int16
    @NSManaged public var blueblackCost: Int16
    @NSManaged public var blackredCost: Int16
    @NSManaged public var redgreenCost: Int16
    @NSManaged public var greenwhiteCost: Int16
    @NSManaged public var whiteblackCost: Int16
    @NSManaged public var blueredCost: Int16
    @NSManaged public var blackgreenCost: Int16
    @NSManaged public var redwhiteCost: Int16//Example: Naya Hushblade
    @NSManaged public var greenblueCost: Int16
    @NSManaged public var whitephyCost: Int16
    @NSManaged public var bluephyCost: Int16//Example: Phyrexian Metamorph
    @NSManaged public var blackphyCost: Int16//Example: Vault Skirge
    @NSManaged public var redphyCost: Int16
    @NSManaged public var greenphyCost: Int16

    //MARK: type inclusion functions
    public func isLand()->Bool{
        return types!.contains("Land")
    }
    public func isPlaneswalker()->Bool{
        return types!.contains("Planeswalker")
    }
    public func isCreature()->Bool{
        return types!.contains("Creature")
    }
    public func isArtifact()->Bool{
        return types!.contains("Artifact")
    }
    public func isEnchantment()->Bool{
        return types!.contains("Enchantment")
    }
    public func isInstant()->Bool{
        return types!.contains("Instant")
    }
    public func isSorcery()->Bool{
        return types!.contains("Sorcery")
    }
    
    //MARK: costs/effects
    /**
     Tries a number of mana pools; returns one that works, or nil if none do
    */
    public func canPayCostFrom(pools: [ManaPool]) -> ManaPool?{
        for pool in pools{
            if self.canPayCostFrom(pool: pool){
                return pool
            }
        }
        return nil
    }//canPayCostFrom pools
    
    public func canPayCostFrom(pool: ManaPool) -> Bool{
        if (whiteCost == 0 && blueCost == 0 && blackCost == 0 && redCost == 0 && greenCost == 0 && anymanaCost == 0 && colorlessCost == 0 && whiteblueCost == 0 && blueblackCost == 0 && blackredCost == 0 && redgreenCost == 0 && greenwhiteCost == 0 && whiteblackCost == 0 && blueredCost == 0 && blackgreenCost == 0 && redwhiteCost == 0 && greenblueCost == 0 && xmanaCost == 0 && whitephyCost == 0 && bluephyCost == 0 && blackphyCost == 0 && redphyCost == 0 && greenphyCost == 0){
            return true
        }//if CMC == 0

        return pool.canCoverCost(ofCard: self)
    }//canPayCostFrom pool
    
    //MARK: Make the MCard
    
    public func copyFromCard(card: Card){
        name = card.name!
        rarity = card.rarity
        text = card.text
        subtypes = card.subtypes
        supertypes = card.supertypes
        types = card.types
        multiverseId = Int64(card.multiverseid!)
        id = card.id!
        flavor = card.flavor
        imageURL = card.imageUrl
        if (card.cmc == nil){
            cmc = -1
        }
        else{
            cmc = Int16(card.cmc!)
        }
        power = card.power
        toughness = card.toughness
        setCode = card.set
        
        isWhite = false; isBlue = false; isBlack = false; isRed = false; isGreen = false; isColorless = true;
        let manaString: String? = card.manaCost
        if manaString != nil{
            let costString: [String] = manaString!.components(separatedBy: CharacterSet(charactersIn: "{}"))
            for cost in costString{
                switch cost{
                case "W":
                    whiteCost += 1
                    isWhite = true
                    isColorless = false
                    break
                
                case "U":
                    blueCost += 1
                    isBlue = true
                    isColorless = false
                    break
                case "B":
                    blackCost += 1
                    isBlack = true
                    isColorless = false
                    break
                case "R":
                    redCost += 1
                    isRed = true
                    isColorless = false
                    break
                case "G":
                    greenCost += 1
                    isGreen = true
                    isColorless = false
                    break
                case "C":
                    colorlessCost += 1
                    break
                case "X":
                    xmanaCost += 1
                    break
                case "W/U":
                    whiteblueCost += 1
                    isWhite = true
                    isBlue = true
                    isColorless = false
                    break
                case "U/B":
                    blueblackCost += 1
                    isBlue = true
                    isBlack = true
                    isColorless = false
                    break
                case "B/R":
                    blackredCost += 1
                    isBlack = true
                    isRed = true
                    isColorless = false
                    break
                case "R/G":
                    redgreenCost += 1
                    isRed = true
                    isGreen = true
                    isColorless = false
                    break
                case "G/W":
                    greenwhiteCost += 1
                    isGreen = true
                    isWhite = true
                    isColorless = false
                    break
                case "W/B":
                    whiteblackCost += 1
                    isWhite = true
                    isBlack = true
                    isColorless = false
                    break
                case "U/R":
                    blueredCost += 1
                    isBlue = true
                    isRed = true
                    isColorless = false
                    break
                case "B/G":
                    blackgreenCost += 1
                    isBlack = true
                    isGreen = true
                    isColorless = false
                    break
                case "R/W":
                    redwhiteCost += 1
                    isRed = true
                    isWhite = true
                    isColorless = false
                    break
                case "G/U":
                    greenblueCost += 1
                    isGreen = true
                    isBlue = true
                    isColorless = false
                    break
                case "W/P":
                    whitephyCost += 1
                    isWhite = true
                    isColorless = false
                    break
                case "U/P":
                    bluephyCost += 1
                    isBlue = true
                    isColorless = false
                    break
                case "B/P":
                    blackphyCost += 1
                    isBlack = true
                    isColorless = false
                    break
                case "R/P":
                    redphyCost += 1
                    isRed = true
                    isColorless = false
                    break
                case "G/P":
                    greenphyCost += 1
                    isGreen = true
                    isColorless = false
                    break
                default:
                    break
                }//switch
                if (Int(cost) != nil){
                    //TODO: handle monocolor hybrids, such as {2/W}; as written, they are treated as uncolored
                    anymanaCost += Int16(Int(cost)!)
                }//if the cost is an int
            }//for each token in the card cost
            
        }//if manastring exists
        
        if (self.text != nil && (self.text!.contains("Devoid"))){
            isWhite = false
            isBlue = false
            isBlack = false
            isRed = false
            isGreen = false
            isColorless = true
        }//if devoid
        
    }//copyFromCard
    
    public static func <(lhs: MCard, rhs: MCard) -> Bool {
        return lhs.name < rhs.name
    }

}//MCard
