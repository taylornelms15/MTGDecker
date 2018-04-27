//
//  ConditionCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/24/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

///Parent class for all kinds of cells in our `RuleTable`. Does not implement any functionality directly.
class ConditionCell: UITableViewCell{
    
    var cardRangeText: [String] = ["0", "1", "2", "3", "4", "5", "6", "7"]
    var handSize: Int16 = 0
    
    var softcon: Softcondition? = nil
    var parentRuleEditVC: RuleEditViewController? = nil
    var path: IndexPath? = nil
    
    func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition? = nil){
        self.path = path
        self.handSize = handSize
        self.softcon = softcon
        
        cardRangeText = Array(cardRangeText.prefix(Int(handSize + 1)))
        
        
    }//softInit
    
    func getLoFieldStrings(forHiValue hi: Int) -> [String]{
        return Array(cardRangeText.prefix(hi + 1))
    }//getLoFieldStrings
    func getHiFieldStrings(forLoValue lo: Int) -> [String]{
        //ex: handsize 6, forLoValue 2
        //cardRangeText = 0 1 2 3 4 5 6, count 7
        
        let reversed: [String] = cardRangeText.reversed() // 6 5 4 3 2 1 0
        let numElements: Int = cardRangeText.count - (lo) // 5 elements
        let cut: [String] = Array(reversed.prefix(numElements)) // 6 5 4 3 2
        
        return cut.reversed() //2 3 4 5 6
    }//getHiFieldStrings
    
    
    
}//ConditionCell
