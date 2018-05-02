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
        default:
            return AbilityParameter.funcNone
        }//switch

    }//parameterFunction
    
    
}//AbilityParameter

enum abParamType: Int32{
    case none
    case tap
    case untap
    case addW
    case addU
    case addB
    case addR
    case addG
    case addC
    case addAny
    case costW
    case costU
    case costB
    case costR
    case costG
    case costC
    case costAny
}//abParamType
