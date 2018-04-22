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
    
    private static var PRECISION = 1.0
    
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
        resultString.append("% 7 Card Hands: \(self.card7String())\n")
        resultString.append("% 6 Card Hands: \(self.card6String())\n")
        resultString.append("% 5 Card Hands: \(self.card5String())\n")
        resultString.append("% 4 Card Hands: \(self.card4String())\n")
        resultString.append("% 3 Card Hands: \(self.card3String())\n")
        
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
    
    public func card7String() -> String{
        let percent = self.card7Percent
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card7String
    public func card6String() -> String{
        let percent = self.card6Percent
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card6String
    public func card5String() -> String{
        let percent = self.card5Percent
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card5String
    public func card4String() -> String{
        let percent = self.card4Percent
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card4String
    public func card3String() -> String{
        let percent = self.card3Percent
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card3String
    
    
    
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
