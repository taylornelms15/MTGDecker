//
//  AddConditionCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/24/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class AddConditionCell: ConditionCell, UIPickerViewDelegate, UIPickerViewDataSource{

    static var conditionTypeOptions: [String] = ["",
                                                 "Contains Number of Lands...",//.landTotal
                                                 "Contains Specific Card...",//.nameEqualTo
                                                 "Contains Card With Property...",//.creatureTotal
                                                 "Contains Playable Card...",//.playable
                                                 "Covers Mana Needs"]//.manaCoverage
    
    
    @IBOutlet var conditionalLabel: UILabel!
    @IBOutlet var conditionAddButton: UIBarButtonItem!
    @IBOutlet var conditionTypeField: UITextField!
    
    var picker: UIPickerView?
    
    override func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition? = nil){
        super.softInit(path: path, handSize: handSize, softcon: softcon)
        
        self.picker = UIPickerView()
        
        self.picker!.delegate = self
        self.picker!.dataSource = self
        
        conditionTypeField.inputView = picker
        conditionTypeField.text = ""
        
        self.updateAddButtonEnabled()
        
        
    }//softInit
    
    
    
    @IBAction func conditionAddPress(_ sender: UIBarButtonItem) {
        
        let newSoftcon = Softcondition()
        
        switch conditionTypeField.text!{
        case AddConditionCell.conditionTypeOptions[1]://.landTotal
            newSoftcon.type = Subcondition.ConditionType.landTotal
            newSoftcon.numParam2 = 0
            newSoftcon.numParam3 = Int(handSize)
            
        default:
            NSLog("Tried to add condition with less-than-savory add-condition text")
            return//should never get to this
        }
        
        //Add the softcondition to the table
        let ruleTable = self.parentRuleEditVC!.ruleTableView!
        
        if self.path!.section >= self.parentRuleEditVC!.softRule.count{
            self.parentRuleEditVC!.softRule.append([newSoftcon])
            
            ruleTable.beginUpdates()
            
            ruleTable.insertSections(IndexSet(integer: self.path!.section + 1), with: .automatic)
            ruleTable.insertRows(at: [IndexPath(row: 0, section: self.path!.section + 1)], with: .automatic)
            ruleTable.reloadSections(IndexSet(integer: self.path!.section) , with: .automatic)
            ruleTable.endUpdates()
            
            
        }//if we're making an OR condition
        else{
            self.parentRuleEditVC!.softRule[self.path!.section].append(newSoftcon)
             
            ruleTable.beginUpdates()
            ruleTable.insertRows(at: [IndexPath(row: self.path!.row + 1, section: self.path!.section)], with: .automatic)
            ruleTable.reloadRows(at: [self.path!], with: .automatic)
            ruleTable.endUpdates()
        }//if we're making an AND condition

        
        
        
        //self.parentRuleEditVC!.ruleTableView.reloadData()
        
    }//conditionAddPress
    
    func updateAddButtonEnabled(){
        if conditionTypeField.text == nil || conditionTypeField.text == ""{
            conditionAddButton.isEnabled = false
        }
        else{
            conditionAddButton.isEnabled = true
        }
    }//updateAddButtonEnabled
    
    //MARK: Picker View Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }//numberOfComponents
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AddConditionCell.conditionTypeOptions.count
    }//numberOfRowsInComponent
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AddConditionCell.conditionTypeOptions[row]
    }//titleForRow
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        conditionTypeField.text = AddConditionCell.conditionTypeOptions[row]
        conditionTypeField.endEditing(true)
        self.updateAddButtonEnabled()
    }
    
    
}//AddConditionCell
