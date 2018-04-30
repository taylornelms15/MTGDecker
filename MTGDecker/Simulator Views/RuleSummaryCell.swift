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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    var keep: KeepRule?
    var success: SuccessRule?
    var handSize: Int = -1
    
    var path: IndexPath?
    
    func softInit(path: IndexPath, keep: KeepRule? = nil, success: SuccessRule? = nil){
        self.path = path
        self.keep = keep
        self.success = success
        
        self.titleLabel!.text = RuleEditTableView.tableTitles[path]!
        
        if keep != nil{
            self.handSize = Int(keep!.handSize)
            self.detailLabel!.text = keep!.summary()
            
        }//if a keep-rule
        else{
            self.handSize = -1
            self.detailLabel!.text = success!.summary()
        }//if a success rule

    }//softInit
    
    
    
}//RuleSummaryCell
