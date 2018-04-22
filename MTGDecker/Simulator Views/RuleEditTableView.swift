//
//  RuleEditTableView.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/18/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class RuleEditTableView: UITableView{

    var mulliganSet: MulliganRuleset?
    var success: SuccessRule?
    
    
    static var tableTitles: [IndexPath: String] = [
        IndexPath(row: 0, section: 0) : "7-Card Hands",
        IndexPath(row: 1, section: 0) : "6-Card Hands",
        IndexPath(row: 2, section: 0) : "5-Card Hands",
        IndexPath(row: 3, section: 0) : "4-Card Hands",
        IndexPath(row: 0, section: 1) : "Hand-Draw Success Condition"
    ]//tableTitles
    static var sectionTitles: [String] = ["Mulligan Rules", "Other Conditions"]
    
    
}//RuleEditTableView
