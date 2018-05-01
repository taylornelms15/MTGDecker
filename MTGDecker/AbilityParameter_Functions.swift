//
//  AbilityParameter_Functions.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 5/1/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation

extension AbilityParameter{
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {T} (tap)
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
 
     */
    static func funcTap(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if location.location != .battlefield || location.index == nil || location.index! < 0 || location.index! >= currentState.battlefield.count{
            return nil
        }//Cannot tap something if it's not on the battlefield, or if we're pointing at a location nowhere close to the battlefield
        
        let myNewState = FieldState(state: currentState)
        
        var myCard: FieldState.FieldCard = myNewState.battlefield[location.index!]
        
        if myCard.isTapped == true{
            return nil
        }//cannot tap an already-tapped card
        else{
            myCard.isTapped = true//tap the card
            return Set<FieldState>([myNewState])
        }//else
        
    }//tap
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {Q} (untap)
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func funcUntap(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if location.location != .battlefield || location.index == nil || location.index! < 0 || location.index! >= currentState.battlefield.count{
            return nil
        }//Cannot untap something if it's not on the battlefield, or if we're pointing at a location nowhere close to the battlefield
        
        let myNewState = FieldState(state: currentState)
        
        var myCard: FieldState.FieldCard = myNewState.battlefield[location.index!]
        
        if myCard.isTapped == false{
            return nil
        }//cannot untap an already-untapped card
        else{
            myCard.isTapped = false//untap the card
            return Set<FieldState>([myNewState])
        }//else
    }//tap
    
    
    
    
}//AbilityParameter_Functions
