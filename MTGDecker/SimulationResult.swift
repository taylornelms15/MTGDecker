//
//  SimulationResult.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/14/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

/**
 This class mostly functions to hold the results of a run of simulations, in terms of hand size percentages and success rule evaluations.
 */
public class SimulationResult: CustomStringConvertible{
    public var numTrials: Int = 0
    public var startingHandSize: Int = 7
    public var card7Successes: Int = 0
    public var card6Successes: Int = 0
    public var card5Successes: Int = 0
    public var card4Successes: Int = 0
    public var card3Successes: Int = 0
    
    public var description: String{
        var resultString = ""
        resultString.append("\(numTrials) total trials\n")
        resultString.append("% 7 Card Hands: \(round(100.0 * card7Percent) /  100.0)\n")
        resultString.append("% 6 Card Hands: \(round(100.0 * card6Percent) /  100.0)\n")
        resultString.append("% 5 Card Hands: \(round(100.0 * card5Percent) /  100.0)\n")
        resultString.append("% 4 Card Hands: \(round(100.0 * card4Percent) /  100.0)\n")
        resultString.append("% 3 Card Hands: \(round(100.0 * card3Percent) /  100.0)\n")
        
        return resultString
    }//description
    
    public var card7Percent: Double{
        get{
            return Double(card7Successes) / Double(numTrials) * 100.0
        }
    }//card7Percent
    public var card6Percent: Double{
        get{
            return Double(card6Successes) / Double(numTrials) * 100.0
        }
    }//card6Percent
    public var card5Percent: Double{
        get{
            return Double(card5Successes) / Double(numTrials) * 100.0
        }
    }//card5Percent
    public var card4Percent: Double{
        get{
            return Double(card4Successes) / Double(numTrials) * 100.0
        }
    }//card4Percent
    public var card3Percent: Double{
        get{
            return Double(card3Successes) / Double(numTrials) * 100.0
        }
    }//card3Percent
    
    static func + (lhs: SimulationResult, rhs: SimulationResult) -> SimulationResult{
        let newResult: SimulationResult = SimulationResult()
        newResult.numTrials = lhs.numTrials + rhs.numTrials
        newResult.card7Successes = lhs.card7Successes + rhs.card7Successes
        newResult.card6Successes = lhs.card6Successes + rhs.card6Successes
        newResult.card5Successes = lhs.card5Successes + rhs.card5Successes
        newResult.card4Successes = lhs.card4Successes + rhs.card4Successes
        newResult.card3Successes = lhs.card3Successes + rhs.card3Successes
        
        return newResult
    }//operator +
    
    static func += ( lhs: inout SimulationResult, rhs: SimulationResult){
        lhs = lhs + rhs
    }//operator +=
    
    
}//SimulationResult
