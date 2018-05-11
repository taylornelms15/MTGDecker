//
//  MCardAbilities.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 5/4/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData
import MTGSDKSwift

extension MCard{
    
    @NSManaged var abilities: Set<Ability>
    
    public func parseForAbilities(withText text: String?, into context: NSManagedObjectContext){
        
        self.abilities = Set<Ability>()
        
        if text != nil{
            let potentialAbilities = MCard.splitIntoAbilityCandidates(rulesText: text!)
            
            for abilityText in potentialAbilities{
                
                let colonIndex: String.Index = abilityText.index(of: ":")!
                let costPotentialText = abilityText[ ..<colonIndex ]
                let effectPotentialText = abilityText[abilityText.index(after: colonIndex)..<abilityText.endIndex ]
                
                //print("Potential ability \"\(abilityText)\"")
                //print("Cost read as: \(costPotentialText)")
                //print("Effect read as: \(effectPotentialText)")
                
                let potentialCost: [[AbilityParameter]] = MCard.matchToParameters(text: String(costPotentialText),
                                                                                  isCost: true, cardName: self.name)
                let potentialEffect: [[AbilityParameter]] = MCard.matchToParameters(text: String(effectPotentialText),
                                                                                    isCost: false, cardName: self.name)
                if potentialCost.contains(where: { (block) -> Bool in
                    return !block.isEmpty
                }) && potentialEffect.contains(where: { (block) -> Bool in
                    return !block.isEmpty
                }){
                    let newAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                    newAbility.costParams = potentialCost
                    newAbility.effectParams = potentialEffect
                    
                    self.abilities.insert(newAbility)
                    
                    print("Card: \(self.name)")
                    print("Potential ability \"\(abilityText)\"")
                    print(newAbility.toString())
                    
                }//if we have a parsed cost AND a parsed effect

            }//for each potential ability
            
            
            
        }//has rules text
        else{
            switch self.name{//edge cases for basic lands, which have abilities but not rules text
            case "Plains":
                let landAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                landAbility.costParams = [[AbilityParameter(.tap)]]
                landAbility.effectParams = [[AbilityParameter(.addW)]]
                self.abilities.insert(landAbility)
            case "Island":
                let landAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                landAbility.costParams = [[AbilityParameter(.tap)]]
                landAbility.effectParams = [[AbilityParameter(.addU)]]
                self.abilities.insert(landAbility)
            case "Swamp":
                let landAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                landAbility.costParams = [[AbilityParameter(.tap)]]
                landAbility.effectParams = [[AbilityParameter(.addB)]]
                self.abilities.insert(landAbility)
            case "Mountain":
                let landAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                landAbility.costParams = [[AbilityParameter(.tap)]]
                landAbility.effectParams = [[AbilityParameter(.addR)]]
                self.abilities.insert(landAbility)
            case "Forest":
                let landAbility: Ability = Ability(entity: Ability.entityDescription(context: context), insertInto: context)
                landAbility.costParams = [[AbilityParameter(.tap)]]
                landAbility.effectParams = [[AbilityParameter(.addG)]]
                self.abilities.insert(landAbility)
            default:
                ()
            }//switch
        }//no rules text (might be basic land)
        
    }//parseForAbilities
    
    
    static func splitIntoAbilityCandidates(rulesText: String) -> [String]{
        
        //separate by line, and pull out reminder text
        let rawSplit: [Substring] = rulesText.split(maxSplits: Int.max, omittingEmptySubsequences: true) { (c) -> Bool in
            if "()\n".contains(c){
                return true
            }//if
            return false
        }//rawSplit
        
        var result: [String] = []
        
        for sub in rawSplit{
            if sub.contains(":"){
                result.append(String(sub))
            }//if
        }//for
        
        return result
        
    }//splitIntoAbilityCandidates
    
    /**
     Splits a string representing an activated ability's cost or effect into its relevant Ability Parameters.
     
     - parameter potential: `String` with the rules text on one side of the activated ability's colon
     - parameter isCost: `Bool` representing whether the text is on the left side of the ability's colon (cost) or the right side (effect)
     - parameter cardName: `String` with the name of the card. Relevant for abilities that contain "{T} CARDNAME".
     - returns: 2D array of `AbilityParameter` objects. Upper-level array is OR'd; inner arrays AND'ed
     */
    static func matchToParameters(text: String, isCost: Bool, cardName: String) -> [[AbilityParameter]]{
        //TODO: Deal with enchantments that give things abilities, or cards that make tokens with abilities
        
        //First, deal with the Add-mana stuff; treating all of these simplistically, and to the exclusion of other text
        if text.contains("Add "){
            let addOptions: [[AbilityParameter]] = matchAddParameters(potential: text, cardName: cardName)
            return addOptions
        }//add
        
        var results: [[AbilityParameter]] = [[]]
        let currentOptionIndex: Int = 0

        if text.contains("{T}"){
            results[currentOptionIndex].append(AbilityParameter(.tap))
        }//if tap

        //Mana Costs
        if isCost{
            
            if MCard.getManaTokens(text: text) != nil{
                results[currentOptionIndex].append(contentsOf: MCard.matchManaCostParams(text: text))
            }//if there are costs that look like mana costs
        
        }//if we're looking at a mana cost
        
        //Card placement manipulation
        
        if text.contains("Sacrifice \(cardName)"){
            results[currentOptionIndex].append(AbilityParameter(.sacrificeSelf))
        }
        if text.contains("Untap target land"){
            results[currentOptionIndex].append(AbilityParameter(.untapLand))
        }
        if text.contains("Untap target basic land"){
            results[currentOptionIndex].append(AbilityParameter(.untapBasicLand))
        }
        if text.contains("Untap target Forest"){
            results[currentOptionIndex].append(AbilityParameter(.untapForest))
        }
        if text.contains("Untap target creature"){
            results[currentOptionIndex].append(AbilityParameter(.untapCreature))
        }
        if text.contains("Untap target artifact or creature"){
            return [[AbilityParameter(.untapArtifact)], [AbilityParameter(.untapCreature)]]
        }//special case for Aphetto Alchemist
        if text.contains("Untap target artifact"){
            results[currentOptionIndex].append(AbilityParameter(.untapArtifact))
        }

        
        return results
    }//matchToParameters
    
    static func matchAddParameters(potential ptext: String, cardName: String) -> [[AbilityParameter]]{

        let text: String = ptext.replacingOccurrences(of: " to your mana pool.", with: ".")
        
        //SINGLE-YIELD
        if (text.contains("Add {W}.")){
            return [[AbilityParameter(.addW)]]
        }
        if (text.contains("Add {U}.")){
            return [[AbilityParameter(.addU)]]
        }
        if (text.contains("Add {B}.")){
            return [[AbilityParameter(.addB)]]
        }
        if (text.contains("Add {R}.")){
            return [[AbilityParameter(.addR)]]
        }
        if (text.contains("Add {G}.")){
            return [[AbilityParameter(.addG)]]
        }
        if (text.contains("Add {C}.")){
            return [[AbilityParameter(.addC)]]
        }
        
        //DUALS (choice)
        if (text.contains("Add {W} or {U}")){
            return [[AbilityParameter(.addW)], [AbilityParameter(.addU)]]
        }//WU
        if (text.contains("Add {U} or {B}")){
            return [[AbilityParameter(.addU)], [AbilityParameter(.addB)]]
        }//UB
        if (text.contains("Add {B} or {R}")){
            return [[AbilityParameter(.addB)], [AbilityParameter(.addR)]]
        }//BR
        if (text.contains("Add {R} or {G}")){
            return [[AbilityParameter(.addR)], [AbilityParameter(.addG)]]
        }//RG
        if (text.contains("Add {G} or {W}")){
            return [[AbilityParameter(.addG)], [AbilityParameter(.addW)]]
        }//GW
        if (text.contains("Add {W} or {B}")){
            return [[AbilityParameter(.addW)], [AbilityParameter(.addB)]]
        }//WB
        if (text.contains("Add {U} or {R}")){
            return [[AbilityParameter(.addU)], [AbilityParameter(.addR)]]
        }//UR
        if (text.contains("Add {B} or {G}")){
            return [[AbilityParameter(.addB)], [AbilityParameter(.addG)]]
        }//BG
        if (text.contains("Add {R} or {W}")){
            return [[AbilityParameter(.addR)], [AbilityParameter(.addW)]]
        }//RW
        if (text.contains("Add {G} or {U}")){
            return [[AbilityParameter(.addG)], [AbilityParameter(.addU)]]
        }//GU
        //COLORLESS MULTIPLES
        if (text.contains("Add {C}{C}{C}")){
            return [[AbilityParameter(.addC), AbilityParameter(.addC), AbilityParameter(.addC)]]
        }
        if (text.contains("Add {C}{C}{R}")){
            return [[AbilityParameter(.addC), AbilityParameter(.addC), AbilityParameter(.addR)]]
        }
        if (text.contains("Add {C}{C}")){
            return [[AbilityParameter(.addC), AbilityParameter(.addC)]]
        }
        
        //TRIPLES
        //Shards
        if (text.contains("Add {B}, {R}, or {G}")){
            return [[AbilityParameter(.addB)], [AbilityParameter(.addR)], [AbilityParameter(.addG)]]
        }//BRG
        if (text.contains("Add {R}, {G}, or {W}")){
            return [[AbilityParameter(.addR)], [AbilityParameter(.addG)], [AbilityParameter(.addW)]]
        }//RGW
        if (text.contains("Add {G}, {W}, or {U}")){
            return [[AbilityParameter(.addG)], [AbilityParameter(.addW)], [AbilityParameter(.addU)]]
        }//GWU
        if (text.contains("Add {W}, {U}, or {B}")){
            return [[AbilityParameter(.addW)], [AbilityParameter(.addU)], [AbilityParameter(.addB)]]
        }//WUB
        if (text.contains("Add {U}, {B}, or {R}")){
            return [[AbilityParameter(.addU)], [AbilityParameter(.addB)], [AbilityParameter(.addR)]]
        }//UBR
        //Wedges
        if (text.contains("Add {G}, {U}, or {R}")){
            return [[AbilityParameter(.addG)], [AbilityParameter(.addU)], [AbilityParameter(.addR)]]
        }//GUR
        if (text.contains("Add {W}, {B}, or {G}")){
            return [[AbilityParameter(.addW)], [AbilityParameter(.addB)], [AbilityParameter(.addG)]]
        }//WBG
        if (text.contains("Add {U}, {R}, or {W}")){
            return [[AbilityParameter(.addU)], [AbilityParameter(.addG)], [AbilityParameter(.addW)]]
        }//URW
        if (text.contains("Add {B}, {G}, or {U}")){
            return [[AbilityParameter(.addB)], [AbilityParameter(.addG)], [AbilityParameter(.addU)]]
        }//BGU
        if (text.contains("Add {R}, {W}, or {B}")){
            return [[AbilityParameter(.addR)], [AbilityParameter(.addW)], [AbilityParameter(.addB)]]
        }//RWB
        
        //ANY-COLOR
        if text.contains("Add one mana of any color"){
            return [[AbilityParameter(.addAny)]]
        }//if
        if text.contains("Add two mana of any one color"){
            return [[AbilityParameter(.addW), AbilityParameter(.addW)],
                    [AbilityParameter(.addU), AbilityParameter(.addU)],
                    [AbilityParameter(.addB), AbilityParameter(.addB)],
                    [AbilityParameter(.addR), AbilityParameter(.addR)],
                    [AbilityParameter(.addG), AbilityParameter(.addG)],
                    [AbilityParameter(.addC), AbilityParameter(.addC)]            ]
        }//if
        if text.contains("Add three mana of any one color"){
            return [[AbilityParameter(.addW), AbilityParameter(.addW), AbilityParameter(.addW)],
                    [AbilityParameter(.addU), AbilityParameter(.addU), AbilityParameter(.addU)],
                    [AbilityParameter(.addB), AbilityParameter(.addB), AbilityParameter(.addB)],
                    [AbilityParameter(.addR), AbilityParameter(.addR), AbilityParameter(.addR)],
                    [AbilityParameter(.addG), AbilityParameter(.addG), AbilityParameter(.addG)],
                    [AbilityParameter(.addC), AbilityParameter(.addC), AbilityParameter(.addC)]]
        }//if
        if text.contains("Add two mana in any combination"){
            return [[AbilityParameter(.addAny), AbilityParameter(.addAny)]]
        }//if
        if text.contains("Add three mana in any combination"){
            return [[AbilityParameter(.addAny), AbilityParameter(.addAny), AbilityParameter(.addAny)]]
        }//if
        if text.contains("Add five mana in any combination"){
            return [[AbilityParameter(.addAny), AbilityParameter(.addAny), AbilityParameter(.addAny), AbilityParameter(.addAny), AbilityParameter(.addAny)]]
        }//if
        
        //FILTER LANDS
        //also, multi-yield
        
        if text.contains("{W}{W}"){
            if text.contains("Add {W}{W}{W}{W}."){
                return [[AbilityParameter(.addW), AbilityParameter(.addW), AbilityParameter(.addW), AbilityParameter(.addW)]]
            }
            if text.contains("Add {W}{W}{W}."){
                return [[AbilityParameter(.addW), AbilityParameter(.addW), AbilityParameter(.addW)]]
            }
            if text.contains("Add {W}{W}."){
                return [[AbilityParameter(.addW), AbilityParameter(.addW)]]
            }//if only that double
            if text.contains("{U}{U}"){
                return [[AbilityParameter(.addW), AbilityParameter(.addW)],
                        [AbilityParameter(.addW), AbilityParameter(.addU)],
                        [AbilityParameter(.addU), AbilityParameter(.addU)]]
            }
            if text.contains("{B}{B}"){
                return [[AbilityParameter(.addW), AbilityParameter(.addW)],
                        [AbilityParameter(.addW), AbilityParameter(.addB)],
                        [AbilityParameter(.addB), AbilityParameter(.addB)]]
            }
            if text.contains("{R}{R}"){
                return [[AbilityParameter(.addW), AbilityParameter(.addW)],
                        [AbilityParameter(.addW), AbilityParameter(.addR)],
                        [AbilityParameter(.addR), AbilityParameter(.addR)]]
            }
            if text.contains("{G}{G}"){
                return [[AbilityParameter(.addW), AbilityParameter(.addW)],
                        [AbilityParameter(.addW), AbilityParameter(.addG)],
                        [AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
        }//if WW
        
        if text.contains("{U}{U}"){
            if text.contains("Add {U}{U}{U}{U}."){
                return [[AbilityParameter(.addU), AbilityParameter(.addU), AbilityParameter(.addU), AbilityParameter(.addU)]]
            }
            if text.contains("Add {U}{U}{U}."){
                return [[AbilityParameter(.addU), AbilityParameter(.addU), AbilityParameter(.addU)]]
            }
            if text.contains("Add {U}{U}."){
                return [[AbilityParameter(.addU), AbilityParameter(.addU)]]
            }//if only that double
            if text.contains("{B}{B}"){
                return [[AbilityParameter(.addU), AbilityParameter(.addU)],
                        [AbilityParameter(.addU), AbilityParameter(.addB)],
                        [AbilityParameter(.addB), AbilityParameter(.addB)]]
            }
            if text.contains("{R}{R}"){
                return [[AbilityParameter(.addU), AbilityParameter(.addU)],
                        [AbilityParameter(.addU), AbilityParameter(.addR)],
                        [AbilityParameter(.addR), AbilityParameter(.addR)]]
            }
            if text.contains("{G}{G}"){
                return [[AbilityParameter(.addU), AbilityParameter(.addU)],
                        [AbilityParameter(.addU), AbilityParameter(.addG)],
                        [AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
        }//if UU
        
        if text.contains("{B}{B}"){
            if text.contains("Add {B}{B}{B}{B}."){
                return [[AbilityParameter(.addB), AbilityParameter(.addB), AbilityParameter(.addB), AbilityParameter(.addB)]]
            }
            if text.contains("Add {B}{B}{B}."){
                return [[AbilityParameter(.addB), AbilityParameter(.addB), AbilityParameter(.addB)]]
            }
            if text.contains("Add {B}{B}."){
                return [[AbilityParameter(.addB), AbilityParameter(.addB)]]
            }//if only that double
            if text.contains("{R}{R}"){
                return [[AbilityParameter(.addB), AbilityParameter(.addB)],
                        [AbilityParameter(.addB), AbilityParameter(.addR)],
                        [AbilityParameter(.addR), AbilityParameter(.addR)]]
            }
            if text.contains("{G}{G}"){
                if cardName == "Cadaverous Bloom"{
                    return [[AbilityParameter(.addB), AbilityParameter(.addB)],
                            [AbilityParameter(.addG), AbilityParameter(.addG)]]
                }
                return [[AbilityParameter(.addB), AbilityParameter(.addB)],
                        [AbilityParameter(.addB), AbilityParameter(.addG)],
                        [AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
        }//if BB
        
        if text.contains("{R}{R}"){
            if text.contains("Add {R}{R}{R}{R}."){
                return [[AbilityParameter(.addR), AbilityParameter(.addR), AbilityParameter(.addR), AbilityParameter(.addR)]]
            }
            if text.contains("Add {R}{R}{R}."){
                return [[AbilityParameter(.addR), AbilityParameter(.addR), AbilityParameter(.addR)]]
            }
            if text.contains("Add {R}{R}."){
                return [[AbilityParameter(.addR), AbilityParameter(.addR)]]
            }//if only that double
            if text.contains("{G}{G}"){
                return [[AbilityParameter(.addR), AbilityParameter(.addR)],
                        [AbilityParameter(.addR), AbilityParameter(.addG)],
                        [AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
        }//if RR
        if text.contains("{G}{G}"){
            if text.contains("Add {G}{G}{G}{G}."){
                return [[AbilityParameter(.addG), AbilityParameter(.addG), AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
            if text.contains("Add {G}{G}{G}."){
                return [[AbilityParameter(.addG), AbilityParameter(.addG), AbilityParameter(.addG)]]
            }
            if text.contains("Add {G}{G}."){
                return [[AbilityParameter(.addG), AbilityParameter(.addG)]]
            }//if only that double
        }//if RR
        
        //COLORLESS-DUALS
        if text.contains("Add {C}{W}."){
            return [[AbilityParameter(.addC), AbilityParameter(.addW)]]
        }
        if text.contains("Add {C}{U}."){
            return [[AbilityParameter(.addC), AbilityParameter(.addU)]]
        }
        if text.contains("Add {C}{B}."){
            return [[AbilityParameter(.addC), AbilityParameter(.addB)]]
        }
        if text.contains("Add {C}{R}."){
            return [[AbilityParameter(.addC), AbilityParameter(.addR)]]
        }
        if text.contains("Add {C}{G}."){
            return [[AbilityParameter(.addC), AbilityParameter(.addG)]]
        }
        
        return [[]]
    }//matchAddParameters
    
    static func matchManaCostParams(text: String) -> [AbilityParameter]{
        var results: [AbilityParameter] = []
        
        let tokenResults: [String] = MCard.getManaTokens(text: text) ?? []
        if tokenResults.count == 0{
            return []
        }
        
        
        for token in tokenResults{
            switch(token){
            case "W", "W/P", "2/W":
                results.append(AbilityParameter(.costW))
            case "U", "U/P", "2/U":
                results.append(AbilityParameter(.costU))
            case "B", "B/P", "2/B":
                results.append(AbilityParameter(.costB))
            case "R", "R/P", "2/R":
                results.append(AbilityParameter(.costR))
            case "G", "G/P", "2/G":
                results.append(AbilityParameter(.costG))
            case "C":
                results.append(AbilityParameter(.costC))
            case "W/U":
                results.append(AbilityParameter(.costWU))
            case "U/B":
                results.append(AbilityParameter(.costUB))
            case "B/R":
                results.append(AbilityParameter(.costBR))
            case "R/G":
                results.append(AbilityParameter(.costRG))
            case "G/W":
                results.append(AbilityParameter(.costGW))
            case "W/B":
                results.append(AbilityParameter(.costWB))
            case "U/R":
                results.append(AbilityParameter(.costUR))
            case "B/G":
                results.append(AbilityParameter(.costBG))
            case "R/W":
                results.append(AbilityParameter(.costRW))
            case "G/U":
                results.append(AbilityParameter(.costGU))
            default://for int-based "any mana" costs
                let intParse: Int? = Int(token)
                if intParse != nil{
                    for _ in 0 ..< intParse!{
                        results.append(AbilityParameter(.costAny))
                    }//for each "any mana" cost
                }//if
            }//switch (by token name)
        }//for each token
        
        return results
    }//matchManaCostParams
    
    static func getManaTokens(text: String)->[String]?{
        let regexString = "\\{([0-9]+|[WUBRGC]|([WUBRG2]/[WUBRGP]))\\}"
        
        let regex = try! NSRegularExpression(pattern: regexString, options: [])
        
        var resultRanges: [String] = []
        
        regex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { (result, flags, pointer) in
            if result != nil{
                let myRange = Range(result!.range)!
                let firstIndex = text.index(text.startIndex, offsetBy: myRange.lowerBound + 1)
                let lastIndex = text.index(text.startIndex, offsetBy: myRange.upperBound - 1)
                resultRanges.append(String(text[firstIndex ..< lastIndex]))
            }
        }//for each match

        if resultRanges.count == 0{return nil}
        
        return resultRanges
    }//getManaTokens
    
}//MCard Abilities














