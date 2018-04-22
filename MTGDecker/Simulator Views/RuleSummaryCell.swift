//
//  RuleSummaryCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/18/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class RuleSummaryCell: UITableViewCell{
    
    var keep: KeepRule?
    var success: SuccessRule?
    var handSize: Int = -1
    
    var path: IndexPath?
    
    func softInit(path: IndexPath, keep: KeepRule? = nil, success: SuccessRule? = nil){
        self.path = path
        self.keep = keep
        self.success = success
        
        self.textLabel!.text = RuleEditTableView.tableTitles[path]!
        
        if keep != nil{
            self.handSize = Int(keep!.handSize)
            self.detailTextLabel!.text = keep!.summary()
            
        }//if a keep-rule
        else{
            self.handSize = -1
            self.detailTextLabel!.text = success!.summary()
        }//if a success rule

        self.detailTextLabel!.adjustsFontSizeToFitWidth = true
        self.detailTextLabel!.minimumScaleFactor = 0.2
    }//softInit
    
    
    
}//RuleSummaryCell
