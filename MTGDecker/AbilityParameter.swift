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

    var parameter: abParamType = .none
    
    enum CodingKeys: String, CodingKey {
        case parameter
    }//CodingKeys

 
    func encode(with aCoder: NSCoder) {
        aCoder.encode(parameter.rawValue, forKey: CodingKeys.parameter.rawValue)
    }//encode
    
    required init?(coder aDecoder: NSCoder) {
        parameter = abParamType(rawValue: aDecoder.decodeInt32(forKey: CodingKeys.parameter.rawValue))!
    }//decode
    
    
}//AbilityParameter

enum abParamType: Int32{
    case none
    case w
    case u
    case b
    case r
    case g
}//abParamType
