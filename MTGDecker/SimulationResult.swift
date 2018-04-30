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
    public var card7Keeps: Int = 0
    public var card6Keeps: Int = 0
    public var card5Keeps: Int = 0
    public var card4Keeps: Int = 0
    public var card3Keeps: Int = 0
    public var card7Success: Int = 0
    public var card6Success: Int = 0
    public var card5Success: Int = 0
    public var card4Success: Int = 0
    public var card3Success: Int = 0
    
    public var description: String{
        var resultString = ""
        resultString.append("\(numTrials) total trials\n")
        resultString.append("% 7 Card Hands: \(self.card7String()), Success: \(self.card7SString())\n")
        resultString.append("% 6 Card Hands: \(self.card6String()), Success: \(self.card6SString())\n")
        resultString.append("% 5 Card Hands: \(self.card5String()), Success: \(self.card5SString())\n")
        resultString.append("% 4 Card Hands: \(self.card4String()), Success: \(self.card4SString())\n")
        resultString.append("% 3 Card Hands: \(self.card3String()), Success: \(self.card3SString())\n")
        
        return resultString
    }//description
    
    //**Keep Percent**
    
    public var card7Percent: Double{
        get{
            return Double(card7Keeps) / Double(numTrials) * 100.0
        }
    }//card7Percent

    public var card6Percent: Double{
        get{
            return Double(card6Keeps) / Double(numTrials) * 100.0
        }
    }//card6Percent
    
    public var card5Percent: Double{
        get{
            return Double(card5Keeps) / Double(numTrials) * 100.0
        }
    }//card5Percent
    public var card4Percent: Double{
        get{
            return Double(card4Keeps) / Double(numTrials) * 100.0
        }
    }//card4Percent
    public var card3Percent: Double{
        get{
            return Double(card3Keeps) / Double(numTrials) * 100.0
        }
    }//card3Percent
    
    //**Success Percent**
    
    public var card7SPercent: Double{
        get{
            return Double(card7Success) / Double(card7Keeps) * 100.0
        }
    }//card7Percent
    
    public var card6SPercent: Double{
        get{
            return Double(card6Success) / Double(card6Keeps) * 100.0
        }
    }//card6Percent
    
    public var card5SPercent: Double{
        get{
            return Double(card5Success) / Double(card5Keeps) * 100.0
        }
    }//card5Percent
    public var card4SPercent: Double{
        get{
            return Double(card4Success) / Double(card4Keeps) * 100.0
        }
    }//card4Percent
    public var card3SPercent: Double{
        get{
            return Double(card3Success) / Double(card3Keeps) * 100.0
        }
    }//card3Percent
    
    
    //**Keep String**
    
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
    
    //**Success String**
    
    public func card7SString() -> String{
        let percent = self.card7SPercent
        if percent.isNaN{
            return ""
        }
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card7String
    public func card6SString() -> String{
        let percent = self.card6SPercent
        if percent.isNaN{
            return ""
        }
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card6String
    public func card5SString() -> String{
        let percent = self.card5SPercent
        if percent.isNaN{
            return ""
        }
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card5String
    public func card4SString() -> String{
        let percent = self.card4SPercent
        if percent.isNaN{
            return ""
        }
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card4String
    public func card3SString() -> String{
        let percent = self.card3SPercent
        if percent.isNaN{
            return ""
        }
        let roundedPercent = round(pow(10.0, SimulationResult.PRECISION) * percent) /  pow(10.0, SimulationResult.PRECISION)
        return "\(roundedPercent)"
    }//card3String
    
    
    
    static func + (lhs: SimulationResult, rhs: SimulationResult) -> SimulationResult{
        let newResult: SimulationResult = SimulationResult()
        newResult.numTrials = lhs.numTrials + rhs.numTrials
        newResult.card7Keeps = lhs.card7Keeps + rhs.card7Keeps
        newResult.card6Keeps = lhs.card6Keeps + rhs.card6Keeps
        newResult.card5Keeps = lhs.card5Keeps + rhs.card5Keeps
        newResult.card4Keeps = lhs.card4Keeps + rhs.card4Keeps
        newResult.card3Keeps = lhs.card3Keeps + rhs.card3Keeps
        newResult.card7Success = lhs.card7Success + rhs.card7Success
        newResult.card6Success = lhs.card6Success + rhs.card6Success
        newResult.card5Success = lhs.card5Success + rhs.card5Success
        newResult.card4Success = lhs.card4Success + rhs.card4Success
        newResult.card3Success = lhs.card3Success + rhs.card3Success
        
        return newResult
    }//operator +
    
    static func += ( lhs: inout SimulationResult, rhs: SimulationResult){
        lhs = lhs + rhs
    }//operator +=
    
    
}//SimulationResult
