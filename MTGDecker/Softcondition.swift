//
//  Softcondition.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation

/**
 Encapsulates the data held within a Subcondition, but without being a NSManagedObject subclass. This is primarily for enhanced mutability when creating rules and conditions.
 */
class Softcondition{
    
    public var type: Subcondition.ConditionType? = nil
    ///An "equal to" given value
    public var numParam1: Int?
    ///A "greater than or equal to" given value
    public var numParam2: Int?
    ///A "less than or equal to" given value
    public var numParam3: Int?
    ///A "color inclusion" given value. Note: should primarily be modified by class methods.
    public var numParam4: Int?
    ///reserved
    public var numParam5: Int?
    ///An "equal to" given value for a string parameter
    public var stringParam1: String?
    ///reserved
    public var stringParam2: String?
    ///A "type" given value. See `typeParam`
    public var typeParam: Subcondition.CardType?
    
    ///A variable to keep track of whether the softcondition could be converted to a Subcondition with its current data.
    public var isValid: Bool = true
    
    public init(from subcon: Subcondition){
        self.type = subcon.type
        self.numParam1 = Int(subcon.numParam1)
        self.numParam2 = Int(subcon.numParam2)
        self.numParam3 = Int(subcon.numParam3)
        self.numParam4 = Int(subcon.numParam4)
        self.numParam5 = Int(subcon.numParam5)
        self.stringParam1 = subcon.stringParam1
        self.stringParam2 = subcon.stringParam2
        self.typeParam = subcon.typeParam
    }//initFromSubcondition
    
    public init(){
        //use default values
    }
    
    
    
}//Softcondition

extension Subcondition{
    
    func copyFrom(_ softcon: Softcondition){
        
        self.type = softcon.type ?? .undefinedTotal
        self.numParam1 = Int16(softcon.numParam1 ?? -1)
        self.numParam2 = Int16(softcon.numParam2 ?? -1)
        self.numParam3 = Int16(softcon.numParam3 ?? -1)
        self.numParam4 = Int16(softcon.numParam4 ?? -1)
        self.numParam5 = Int16(softcon.numParam5 ?? -1)
        self.stringParam1 = softcon.stringParam1
        self.stringParam2 = softcon.stringParam2
        self.typeParam = softcon.typeParam ?? .none
        
        
    }//copyFromSoftcondition
    
    
}//Subcondition extension
