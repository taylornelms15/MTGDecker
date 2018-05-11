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
     
     Relevant ability text: none
     
     Does nothing to the state; just copies it and returns it in a set
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func funcNone(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let newState = FieldState(state: currentState)
        return Set<FieldState>([newState])
        
    }//none
    
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
        
        if myCard.isTapped == true || myCard.isSick == true{
            return nil
        }//cannot tap an already-tapped card, or one with summoning sickness
        else{
            myCard.isTapped = true//tap the card
            myNewState.battlefield[location.index!] = myCard
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
            myNewState.battlefield[location.index!] = myCard
            return Set<FieldState>([myNewState])
        }//else
    }//untap
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {W}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addW(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.w += 1
        
        return Set<FieldState>([resultState])
    }//addW
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {U}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addU(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.u += 1
        
        return Set<FieldState>([resultState])
    }//addU
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {B}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addB(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.b += 1
        
        return Set<FieldState>([resultState])
    }//addB
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {R}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addR(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.r += 1
        
        return Set<FieldState>([resultState])
    }//addR
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {G}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addG(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.g += 1
        
        return Set<FieldState>([resultState])
    }//addG
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add {C}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addC(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.c += 1
        
        return Set<FieldState>([resultState])
    }//addC
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Add one mana of any color
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func addAny(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        let resultStateW = FieldState(state: currentState)
        let resultStateU = FieldState(state: currentState)
        let resultStateB = FieldState(state: currentState)
        let resultStateR = FieldState(state: currentState)
        let resultStateG = FieldState(state: currentState)
        let resultStateC = FieldState(state: currentState)
        
        resultStateW.manaPool.w += 1
        resultStateU.manaPool.u += 1
        resultStateB.manaPool.b += 1
        resultStateR.manaPool.r += 1
        resultStateG.manaPool.g += 1
        resultStateC.manaPool.c += 1
        
        return Set<FieldState>([resultStateW, resultStateU, resultStateB, resultStateR, resultStateG, resultStateC])
    }//addAny
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {W}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costW(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.w <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.w -= 1
        
        return Set<FieldState>([resultState])
    }//costW
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {U}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costU(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.u <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.u -= 1
        
        return Set<FieldState>([resultState])
    }//costU
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {B}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costB(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.b <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.b -= 1
        
        return Set<FieldState>([resultState])
    }//costB
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {R}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costR(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.r <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.r -= 1
        
        return Set<FieldState>([resultState])
    }//costR
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {G}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costG(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.g <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.g -= 1
        
        return Set<FieldState>([resultState])
    }//costG
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {C}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costC(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if currentState.manaPool.c <= 0{
            return nil
        }
        let resultState = FieldState(state: currentState)
        
        resultState.manaPool.c -= 1
        
        return Set<FieldState>([resultState])
    }//costC
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {1}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costAny(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.w > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.w -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.u > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.u -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.b > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.b -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.r > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.r -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.g > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.g -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.c > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.c -= 1
            resultStates.insert(resultState)
        }
        
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costAny
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {W/U}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costWU(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.w > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.w -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.u > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.u -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costWU
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {U/B}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costUB(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.u > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.u -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.b > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.b -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costUB
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {B/R}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costBR(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.b > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.b -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.r > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.r -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costBR
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {R/G}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costRG(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.r > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.r -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.g > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.g -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costRG
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {G/W}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costGW(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.g > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.g -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.w > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.w -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costGW
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {W/B}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costWB(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.w > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.w -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.b > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.b -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costWB
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {U/R}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costUR(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.u > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.u -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.r > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.r -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costUR
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {B/G}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costBG(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.b > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.b -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.g > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.g -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costBG
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {R/W}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costRW(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.r > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.r -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.w > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.w -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costRW
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: {G/U}
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func costGU(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        if currentState.manaPool.g > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.g -= 1
            resultStates.insert(resultState)
        }
        if currentState.manaPool.u > 0{
            let resultState: FieldState = FieldState(state: currentState)
            resultState.manaPool.u -= 1
            resultStates.insert(resultState)
        }
        
        if resultStates.count > 0{
            return resultStates
        }
        return nil
    }//costGU
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Sacrifice [cardname]
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func sacrificeSelf(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        if location.location != .battlefield || location.index == nil || location.index! < 0 || location.index! >= currentState.battlefield.count{
            return nil
        }//Cannot sacrifice something if it's not on the battlefield, or if we're pointing at a location nowhere close to the battlefield
        
        let myNewState = FieldState(state: currentState)
        let myCard: FieldState.FieldCard = myNewState.battlefield[location.index!]
        
        myNewState.battlefield.remove(at: location.index!)
        myNewState.graveyard.append(myCard.card)
        
        return Set<FieldState>([myNewState])
    }//sacrifice
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Untap target land
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func untapLand(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let validLands = currentState.battlefield.filter { (fieldCard) -> Bool in
            return fieldCard.card.isLand() && fieldCard.isTapped
        }//filter down to the tapped lands
        
        if validLands.count < 1{
            return nil
        }//if
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for landFieldcard in validLands{
            let newState: FieldState = FieldState(state: currentState)
            let validIndex = newState.battlefield.index { (candidate) -> Bool in
                return candidate == landFieldcard
            }!
            newState.battlefield[validIndex].isTapped = true
            resultStates.insert(newState)
        }//for each valid, tapped land

        return resultStates
    }//untapLand
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Untap target Forest
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func untapForest(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let validLands = currentState.battlefield.filter { (fieldCard) -> Bool in
            return fieldCard.card.isLand() && fieldCard.isTapped && (fieldCard.card.subtypes?.contains("Forest") ?? false)
        }//filter down to the tapped lands
        
        if validLands.count < 1{
            return nil
        }//if
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for landFieldcard in validLands{
            let newState: FieldState = FieldState(state: currentState)
            let validIndex = newState.battlefield.index { (candidate) -> Bool in
                return candidate == landFieldcard
                }!
            newState.battlefield[validIndex].isTapped = true
            resultStates.insert(newState)
        }//for each valid, tapped land
        
        return resultStates
    }//untapForest
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Untap target basic land
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func untapBasicLand(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let validLands = currentState.battlefield.filter { (fieldCard) -> Bool in
            return fieldCard.card.isLand() && fieldCard.isTapped && (fieldCard.card.supertypes?.contains("Basic") ?? false)
        }//filter down to the tapped lands
        
        if validLands.count < 1{
            return nil
        }//if
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for landFieldcard in validLands{
            let newState: FieldState = FieldState(state: currentState)
            let validIndex = newState.battlefield.index { (candidate) -> Bool in
                return candidate == landFieldcard
                }!
            newState.battlefield[validIndex].isTapped = true
            resultStates.insert(newState)
        }//for each valid, tapped land
        
        return resultStates
    }//untapBasicLand
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Untap target creature
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func untapCreature(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let validLands = currentState.battlefield.filter { (fieldCard) -> Bool in
            return fieldCard.card.isCreature() && fieldCard.isTapped
        }//filter down to the tapped creatures
        
        if validLands.count < 1{
            return nil
        }//if
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for landFieldcard in validLands{
            let newState: FieldState = FieldState(state: currentState)
            let validIndex = newState.battlefield.index { (candidate) -> Bool in
                return candidate == landFieldcard
                }!
            newState.battlefield[validIndex].isTapped = true
            resultStates.insert(newState)
        }//for each valid, tapped creature
        
        return resultStates
    }//untapCreature
    
    /**
     Executes a given parameter of an ability and returns a set of possible states after that parameter's execution.
     
     Relevant ability text: Untap target artifact
     
     - parameter currentState: The current state of the playing field
     - parameter location: The location of the card whose ability we are activating
     - returns: Set of all possible field states after execution of ability parameter. If execution is impossible for whatever reason (such as if a cost cannot be paid, or no valid target exists), returns nil.
     
     */
    static func untapArtifact(currentState: FieldState, location: CardLocation) -> Set<FieldState>?{
        
        let validLands = currentState.battlefield.filter { (fieldCard) -> Bool in
            return fieldCard.card.isArtifact() && fieldCard.isTapped
        }//filter down to the tapped artifacts
        
        if validLands.count < 1{
            return nil
        }//if
        
        var resultStates: Set<FieldState> = Set<FieldState>()
        
        for landFieldcard in validLands{
            let newState: FieldState = FieldState(state: currentState)
            let validIndex = newState.battlefield.index { (candidate) -> Bool in
                return candidate == landFieldcard
                }!
            newState.battlefield[validIndex].isTapped = true
            resultStates.insert(newState)
        }//for each valid, tapped artifact
        
        return resultStates
    }//untapArtifact
    
}//AbilityParameter_Functions
