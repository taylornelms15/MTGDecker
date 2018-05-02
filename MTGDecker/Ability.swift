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
    
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    
    func canPayCost(currentState: FieldState, at location: CardLocation) -> Bool{
        
        
        return false
    }//canPayCost
    
    func executeCost(currentState: FieldState, atLocation: CardLocation) -> Set<FieldState>?{
        
        var result = Set<FieldState>()
        
        for andBlock in costParams{
            
            let thisState = FieldState(state: currentState)
            //make a list to hold the possible states after paying any of the cost options
            var working = Set<FieldState>([thisState])
            
            for cost in andBlock{
                
                var subWorking = Set<FieldState>()
                
                let costFunction = AbilityParameter.parameterFunction(cost.parameter)
                
                for state in working{
                    //for each of the possible states (either the starting state, or what resulted from paying part of the cost), make a list of the resulting states from paying this part of the cost
                    subWorking.formUnion(costFunction(state, atLocation) ?? Set<FieldState>())
                }//for each state we're anding
                
                //replace the possible states with the possible states after paying this part of the cost
                working = subWorking
                
            }//for each cost in the andBlock
            
            //add the possible cost-paid states to the result
            result.formUnion(working)
            
        }//for each andBlock
        
        if result.count != 0{
            return result
        }//if

        return nil
    }//payCost
    
    func executeEffect(currentState: FieldState, atLocation: CardLocation) -> Set<FieldState>?{
        
        var result = Set<FieldState>()
        
        for andBlock in effectParams{
            
            let thisState = FieldState(state: currentState)
            //make a list to hold the possible states after executing any of the effect options
            var working = Set<FieldState>([thisState])
            
            for effect in andBlock{
                
                var subWorking = Set<FieldState>()
                
                let effectFunction = AbilityParameter.parameterFunction(effect.parameter)
                
                for state in working{
                    //for each of the possible states (either the starting state, or what resulted from executing part of the effect), make a list of the resulting states from executing this part of the effect
                    subWorking.formUnion(effectFunction(state, atLocation) ?? Set<FieldState>())
                }//for each state we're anding
                
                //replace the possible states with the possible states after executing this part of the effect
                working = subWorking
                
            }//for each effect in the andBlock
            
            //add the possible effect-executed states to the result
            result.formUnion(working)
            
        }//for each andBlock
        
        if result.count != 0{
            return result
        }//if
        
        return nil
    }//executeEffect
    
    func executeAbility(currentState: FieldState, at location: CardLocation) -> Set<FieldState>?{

        let currentCard: MCard = currentState.cardAtLocation(location)!
        
        let costPaidStates: Set<FieldState>? = self.executeCost(currentState: currentState, atLocation: location)
        
        if costPaidStates == nil{
            return nil
        }
        
        var result: Set<FieldState> = Set<FieldState>()
        
        for state in costPaidStates!{
            
            var changedLocation: CardLocation? = nil
            
            if state.cardAtLocation(location) != currentCard{
                changedLocation = state.newLocation(for: currentCard, insteadof: location)
                if changedLocation == nil{
                    //TODO: deal with cards going into exile?
                    print("A card just got knocked off the table and out of the game in the process of activating its effect.")
                    print("I'm sorry for your loss. It was \(currentCard), and the play field was like \n\(currentState)\n***And then it became***\n\(state)")
                }//if
            }//if our card moved
            
            let effectsStates: Set<FieldState>? = self.executeEffect(currentState: state, atLocation: changedLocation ?? location)
            
            if effectsStates != nil{
                result.formUnion(effectsStates!)
            }//if
            else{
                return nil
            }//else
            
        }//for each state where the cost is paid
        
        return result
    }//executeAbility
    
}//Ability
