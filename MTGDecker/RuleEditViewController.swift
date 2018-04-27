//
//  RuleEditViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/22/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RuleEditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var ruleTableView: RuleTable!
    @IBOutlet var ruleNameLabel: UILabel!
    @IBOutlet var defaultsTextField: UITextField!
    
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var keep: KeepRule?
    var success: SuccessRule?
    var handSize: Int16 = 0
    var deck: Deck?
    
    var softRule: [[Softcondition]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ruleTableView.dataSource = self
        ruleTableView.delegate = self
        
        if self.keep != nil{
            self.handSize = keep!.handSize
            
            switch self.keep!.handSize{
            case 7:
                ruleNameLabel.text = "7-Card Keep Rule"
            case 6:
                ruleNameLabel.text = "6-Card Keep Rule"
            case 5:
                ruleNameLabel.text = "5-Card Keep Rule"
            default:
                ruleNameLabel.text = "4-Card Keep Rule"
            }//switch
            
            self.initSoftrule(with: self.keep!)
        }//if a keep rule
        else{
            ruleNameLabel.text = "Success Rule"
            
            self.initSoftrule(using: self.success!)
        }//else (a success rule)
        
    }//viewDidLoad
    
    func initSoftrule(with keep: KeepRule){
        var newSoftrule: [[Softcondition]] = []
        for cond in keep.conditionList ?? []{
            var condArray: [Softcondition] = []
            for subcond in cond.subconditionList ?? []{
                let newSoftcon = Softcondition(from: subcond)
                condArray.append(newSoftcon)
            }//for each subcondition
            newSoftrule.append(condArray)
        }//for each condition
        
        self.softRule = newSoftrule
        
    }//initSoftrule with keeprule
    
    func initSoftrule(using success: SuccessRule){
        var newSoftrule: [[Softcondition]] = []
        for cond in success.conditionList ?? []{
            var condArray: [Softcondition] = []
            for subcond in cond.subconditionList ?? []{
                condArray.append(Softcondition(from: subcond))
            }//for each subcondition
            newSoftrule.append(condArray)
        }//for each condition
        
        self.softRule = newSoftrule
    }//initSoftrule with successrule
    
    //MARK: UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numArrays: Int = 0
        
        for subsection in softRule{
            if subsection.isEmpty == false{
                numArrays += 1
            }
        }
        
        return numArrays + 1 //include at least one section; put at least one "add" button in a fresh section
    }//numberOfSections
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return nil //no header for first section
        }
        else{
            if section == self.softRule.count{
                return nil
            }//no header on the last entry (let the add-condition cell prompt "OR")
            else{
                return "OR"
            }
        }
    }//titleForHeaderInSection
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= softRule.count{
            return 1
        }
        else{
            return softRule[section].count + 1
        }
    }//numberOfRowsInSection
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell: ConditionCell?
        
        
        if indexPath.section >= softRule.count{
            myCell = ruleTableView.dequeueReusableCell(withIdentifier: "addConditionCell") as! AddConditionCell
            myCell!.softInit(path: indexPath, handSize: self.handSize)
            
            (myCell as! AddConditionCell).conditionalLabel.text = "OR"
        }//if we're on the last or after-last section (make an "add new condition" cell)
        else{
            if indexPath.row >= softRule[indexPath.section].count{
                myCell = ruleTableView.dequeueReusableCell(withIdentifier: "addConditionCell") as! AddConditionCell
                myCell!.softInit(path: indexPath, handSize: self.handSize)
                
                (myCell as! AddConditionCell).conditionalLabel.text = "AND"
            }//if we're on the last or after-last row (make an "add new condition" cell)
            else{
                let softcon = softRule[indexPath.section][indexPath.row]
                switch softcon.type!{
                case .landTotal://a land-total condition
                    
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "landTotalCell") as! LandConditionCell
                    myCell!.softInit(path: indexPath, handSize: self.handSize, softcon: softcon)
                default:
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "addConditionCell") as! AddConditionCell
                    myCell!.softInit(path: indexPath, handSize: self.handSize)
                    
                    (myCell as! AddConditionCell).conditionalLabel.text = "???"
                    
                }//switch (softcondition type)
                
                
            }//if we're pulling from a softcondition
            
            
        }//if we're in a section with at least one softCondition
        
        
        
        myCell!.parentRuleEditVC = self
        
        
        return myCell!
    }//cellForRowAt
    
    
    
    
    
}//RuleEditViewController
