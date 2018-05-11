//
//  AbilityParameter.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 5/1/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

class AbilityParameter: NSObject, NSCoding{

    var parameter: abParamType
    var isManaGenerator: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case parameter
    }//CodingKeys

 
    func encode(with aCoder: NSCoder) {
        aCoder.encode(parameter.rawValue, forKey: CodingKeys.parameter.rawValue)
    }//encode
    
    required init?(coder aDecoder: NSCoder) {
        parameter = abParamType(rawValue: aDecoder.decodeInt32(forKey: CodingKeys.parameter.rawValue))!
    }//decode
    
    
    override init(){
        self.parameter = .none
    }//init
    
    init(_ parameter: abParamType){
        self.parameter = parameter
    }//init
    
    init(_ parameter: abParamType, generatesMana: Bool){
        self.parameter = parameter
        self.isManaGenerator = generatesMana
    }//init
    
    func toString()->String{
        return "\(parameter)"
    }
    
    
    static func parameterFunction(_ parameter: abParamType)->((FieldState, CardLocation) -> Set<FieldState>? ){
        switch parameter{
        case .none:
            return AbilityParameter.funcNone
        case .tap:
            return AbilityParameter.funcTap
        case .untap:
            return AbilityParameter.funcUntap
        case .addW:
            return AbilityParameter.addW
        case .addU:
            return AbilityParameter.addU
        case .addB:
            return AbilityParameter.addB
        case .addR:
            return AbilityParameter.addR
        case .addG:
            return AbilityParameter.addG
        case .addC:
            return AbilityParameter.addC
        case .addAny:
            return AbilityParameter.addAny
            
        case .costW:
            return AbilityParameter.costW
        case .costU:
            return AbilityParameter.costU
        case .costB:
            return AbilityParameter.costB
        case .costR:
            return AbilityParameter.costR
        case .costG:
            return AbilityParameter.costG
        case .costC:
            return AbilityParameter.costC
        case .costAny:
            return AbilityParameter.costAny
        case .costWU:
            return AbilityParameter.costWU
        case .costUB:
            return AbilityParameter.costUB
        case .costBR:
            return AbilityParameter.costBR
        case .costRG:
            return AbilityParameter.costRG
        case .costGW:
            return AbilityParameter.costGW
        case .costWB:
            return AbilityParameter.costWB
        case .costUR:
            return AbilityParameter.costUR
        case .costBG:
            return AbilityParameter.costBG
        case .costRW:
            return AbilityParameter.costRW
        case .costGU:
            return AbilityParameter.costGU
            
        case .untapLand:
            return AbilityParameter.untapLand
        case .untapBasicLand:
            return AbilityParameter.untapBasicLand
        case .untapForest:
            return AbilityParameter.untapForest
        case .untapArtifact:
            return AbilityParameter.untapArtifact
        case .untapCreature:
            return AbilityParameter.untapCreature
            
        case .sacrificeSelf:
            return AbilityParameter.sacrificeSelf
            
        default:
            return AbilityParameter.funcNone
        }//switch

    }//parameterFunction
    
    func generatesMana()->Bool{
        switch parameter{
        case .addW, .addU, .addB,.addR, .addG, .addC, .addAny:
            return true
        default:
            return false
        }//switch
    }//generatesMana
    
    /**
        The total mana yield of this Ability Parameter
    */
    func manaYield()->Int{
        switch parameter{
        case .addW, .addU, .addB,.addR, .addG, .addC, .addAny:
            return 1
        case .costW, .costU, .costB, .costR, .costG, .costC, .costAny,
             .costWU, .costUB, .costBR, .costRG, .costGW,
             .costWB, .costUR, .costBG, .costRW, .costGU:
            return -1
        default:
            return 0
        }//switch
    }//manaYield
    
}//AbilityParameter

enum abParamType: Int32{
    case none
    
    //tap
    case tap
    case untap
    case tapUntapped
    
    //Add mana
    case addW
    case addU
    case addB
    case addR
    case addG
    case addC
    case addAny
    
    //Cost mana
    case costW
    case costU
    case costB
    case costR
    case costG
    case costC
    case costAny
    
    //Cost hybrid
    case costWU
    case costUB
    case costBR
    case costRG
    case costGW
    case costWB
    case costUR
    case costBG
    case costRW
    case costGU
    
    //Untap target (TODO: implement)
    case untapLand
    case untapBasicLand
    case untapForest
    case untapCreature
    case untapArtifact
    
    case sacrificeSelf
    
    
    
}//abParamType
