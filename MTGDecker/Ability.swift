//
//  Ability.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 5/1/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

class Ability: NSManagedObject{
    
    ///2D array of parameters representing the cost of the ability. OR the elements in the upper level, AND the elements in the lower level
    @NSManaged var costParams: [[AbilityParameter]]
    ///2D array of parameters representing the effect of the ability. OR the elements in the upper level, AND the elements in the lower level
    @NSManaged var effectParams: [[AbilityParameter]]
    
    
    func canPayCost(currentState: FieldState, at location: CardLocation) -> Bool{
        
        return false
    }//canPayCost
    
    func executeAbility(currentState: FieldState, at location: CardLocation) -> Set<FieldState>?{

        
        return nil
    }//executeAbility
    
}//Ability
