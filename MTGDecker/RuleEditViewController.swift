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
            
            self.handSize = Int16(7)//Default to 7-card hand size for the purposes of limiting Totals condition
            
            self.initSoftrule(using: self.success!)
        }//else (a success rule)
        
    }//viewDidLoad
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.storeRule()
        
    }//viewWillDisappear

    func initSoftrule(with keep: KeepRule){
        let newSoftrule: [[Softcondition]] = KeepRule.makeSoftKeep(keep)
        self.softRule = newSoftrule
    }//initSoftrule with keeprule
    
    func initSoftrule(using success: SuccessRule){
        let newSoftrule: [[Softcondition]] = SuccessRule.makeSoftSuccess(success)
        self.softRule = newSoftrule
    }//initSoftrule with successrule
    
    func storeRule(){
        
        if keep != nil{
            
            let newKeep: KeepRule = KeepRule(entity: KeepRule.entityDescription(context: context), insertInto: context)
            newKeep.handSize = self.handSize
            
            newKeep.copyFromSoft(softArrays: softRule, into: context)
            
            if newKeep == self.keep{
                context.performAndWait {
                    context.delete(newKeep)
                    
                    do{
                        try context.save()
                    }catch{
                        NSLog("Found an error after deleting superfluous rule: \(error)")
                    }
                }//performandwait
                return
            }//if we didn't change anything

            let myDeck = self.deck!
            var activeMullSet = self.deck!.activeMulliganRuleset!
            
            if activeMullSet.isDefault{
                
                let newMullSet: MulliganRuleset = MulliganRuleset(entity: MulliganRuleset.entityDescription(context: context), insertInto: context)
                
                newMullSet.copyFromOther(activeMullSet, into: context)
                
                myDeck.mulliganRulesets!.insert(newMullSet)
                myDeck.activeMulliganRuleset = newMullSet
                
                activeMullSet = newMullSet
                
            }//if it's a default, make a new one, then modify that
            
            switch handSize{
            case 7:
                activeMullSet.keepRule7 = newKeep
            case 6:
                activeMullSet.keepRule6 = newKeep
            case 5:
                activeMullSet.keepRule5 = newKeep
            default:
                activeMullSet.keepRule4 = newKeep
            }//switch
            
            
        }//if a keep rule
        else{
            
            let newSuccess: SuccessRule = SuccessRule(entity: SuccessRule.entityDescription(context: context), insertInto: context)
            
            newSuccess.copyFromSoft(softArrays: softRule, into: context)
            
            if newSuccess == self.success{
                context.performAndWait {
                    context.delete(newSuccess)
                    
                    do{
                        try context.save()
                    }catch{
                        NSLog("Found an error after deleting superfluous rule: \(error)")
                    }
                }//performandwait
                return
            }//if we didn't change anything
            
            let myDeck = self.deck!

            myDeck.activeSuccessRule = newSuccess
                
            myDeck.successRuleList.insert(newSuccess)
            
        }//if a success rule
        
        context.performAndWait {
            do{
                try context.save()
            }//do
            catch{
                NSLog("Error storing new rule: \(error)")
            }//catch
        }//performAndWait
        
        
    }//storeRule
    
    //MARK: UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numArrays: Int = 0
        
        for subsection in softRule{
            if subsection.isEmpty == false{
                numArrays += 1
            }
        }//for
        
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
            }//else
        }//else
    }//titleForHeaderInSection
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
    }//willDisplayHeaderView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= softRule.count{
            return 1
        }//if
        else{
            return softRule[section].count + 1
        }//else
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
                case .nameEqualTo:
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "specificCardCell") as! SpecificCardCell
                    (myCell as! SpecificCardCell).setCardNameChoices(deck: self.deck!)
                    myCell!.softInit(path: indexPath, handSize: self.handSize, softcon: softcon)
                case .creatureTotal, .planeswalkerTotal, .artifactTotal, .enchantmentTotal, .instantTotal, .sorceryTotal, .supertypeEqualTo, .undefinedTotal:
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "cardPropertyCell") as! CardPropertyCell
                    myCell!.softInit(path: indexPath, handSize: self.handSize, softcon: softcon)
                case .playable, .playableByTurn:
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "playableCell") as! PlayableCell
                    myCell!.softInit(path: indexPath, handSize: self.handSize, softcon: softcon)
                case .manaCoverage:
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "manaCoverageCell") as! ManaCoverageCell
                    myCell?.softInit(path: indexPath, handSize: self.handSize, softcon: softcon)
                default://shouldn't get here
                    myCell = ruleTableView.dequeueReusableCell(withIdentifier: "addConditionCell") as! AddConditionCell
                    myCell!.softInit(path: indexPath, handSize: self.handSize)
                    
                    (myCell as! AddConditionCell).conditionalLabel.text = "???"
                    
                }//switch (softcondition type)
                
            }//if we're pulling from a softcondition
            
        }//if we're in a section with at least one softCondition
        
        myCell!.parentRuleEditVC = self
        
        
        return myCell!
    }//cellForRowAt
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section >= softRule.count{
            return false
        }//if we're on the last or after-last section (an "add new condition" cell)
        else{
            if indexPath.row >= softRule[indexPath.section].count{
                return false
            }//if we're on the last or after-last row (an "add new condition" cell)
        }//else
        
        return true//allow deletion of all other cells
    }//canEditRowAt
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if softRule[indexPath.section].count == 1{
                
                softRule.remove(at: indexPath.section)//delete the whole section
                
                if softRule.count == 0{
                    softRule = [[]]
                }
                
                ruleTableView.beginUpdates()
                ruleTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                ruleTableView.reloadData()
                /*
                if self.numberOfSections(in: ruleTableView) > indexPath.section + 1{
                    ruleTableView.reloadSections(IndexSet(integer: indexPath.section + 1), with: .none)
                }//if there's a section after the one we're deleting
                if indexPath.section != 0{
                    ruleTableView.reloadSections(IndexSet(integer: indexPath.section - 1), with: .none)
                }*/
                ruleTableView.endUpdates()
                
            }//if deleting last row in a section
            else{
                softRule[indexPath.section].remove(at: indexPath.row)//delete the softcondition from the softRule
                
                ruleTableView.beginUpdates()
                ruleTableView.deleteRows(at: [indexPath], with: .automatic)
                ruleTableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                ruleTableView.endUpdates()
                
            }//else

        }//deleting
        
    }//commitEditingStyle (delete that row)

}//RuleEditViewController
