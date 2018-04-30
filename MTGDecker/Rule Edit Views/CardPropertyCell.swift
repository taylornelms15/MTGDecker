//
//  CardPropertyCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/29/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class CardPropertyCell: ConditionCell, UIPickerViewDataSource, UIPickerViewDelegate{

    
    
    static var typeOptions: [String] = ["",
                                        "creature",
                                        "planeswalker",
                                        "artifact",
                                        "enchantment",
                                        "instant",
                                        "sorcery",
                                        "legendary"
                                        ]
    
    @IBOutlet var loField: UITextField!
    @IBOutlet var hiField: UITextField!
    @IBOutlet var typeField: UITextField!
    
    private var loVal: Int = 0
    private var hiVal: Int = 0
    
    var loPicker: UIPickerView?
    var hiPicker: UIPickerView?
    var typePicker: UIPickerView?
    
    override func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition?) {
        super.softInit(path: path, handSize: handSize, softcon: softcon)
        
        loPicker = UIPickerView()
        hiPicker = UIPickerView()
        typePicker = UIPickerView()
        
        self.setLoHiFromSoftcon(softcon)
        
        //Put text in based on type
        if softcon != nil{
 
            if softcon!.type != nil{
                switch softcon!.type!{
                case .creatureTotal:
                    typeField.text = CardPropertyCell.typeOptions[1]
                case .planeswalkerTotal:
                    typeField.text = CardPropertyCell.typeOptions[2]
                case .artifactTotal:
                    typeField.text = CardPropertyCell.typeOptions[3]
                case .enchantmentTotal:
                    typeField.text = CardPropertyCell.typeOptions[4]
                case .instantTotal:
                    typeField.text = CardPropertyCell.typeOptions[5]
                case .sorceryTotal:
                    typeField.text = CardPropertyCell.typeOptions[6]
                case .supertypeEqualTo:
                    if softcon!.stringParam1 != nil && softcon!.stringParam1 == "Legendary"{
                        typeField.text = CardPropertyCell.typeOptions[7]
                    }//if legendary supertype
                    else{typeField.text = CardPropertyCell.typeOptions[0]}//""
                default:
                    typeField.text = CardPropertyCell.typeOptions[0]//""
                }//switch
            }//if
            else{
                typeField.text = CardPropertyCell.typeOptions[0]//""
            }//else
            
            
        }//if
        
        
        loPicker!.dataSource = self
        loPicker!.delegate = self
        hiPicker!.dataSource = self
        hiPicker!.delegate = self
        typePicker!.dataSource = self
        typePicker!.delegate = self
        
        loField.inputView = loPicker
        hiField.inputView = hiPicker
        typeField.inputView = typePicker
        
        self.updateFieldBorder()
        
    }//softInit
    
    func setLoHiFromSoftcon(_ softcon: Softcondition?) {
        if self.softcon != nil{
            loVal = softcon!.numParam2 == -1 ? 0 : softcon!.numParam2 ?? 0 //if the parameter is nil or -1, make the value 0; else, make the value what's written
            hiVal = softcon!.numParam3 == -1 ? Int(self.handSize) : softcon!.numParam3 ?? Int(self.handSize) //if the parameter is nil or -1, make the value the hand size; else, make the value what's written
            
            self.softcon!.numParam2 = loVal
            self.softcon!.numParam3 = hiVal
            
            self.loField.text = "\(loVal)"
            self.hiField.text = "\(hiVal)"
            
        }//if
    }//setLoHiFromSoftcon
    
    /**
     Checks the contents of the text field. If they are selecting a valid type, the field has no border, and is good to go. Otherwise, sets the border color to red, to indicate a missing parameter
     */
    func updateFieldBorder(){
        
        if typeField.text == nil || typeField.text == "" || !CardPropertyCell.typeOptions.contains(typeField.text!){
            typeField.layer.borderWidth = RED_BORDER_WIDTH
            typeField.layer.cornerRadius = RED_BORDER_CURVE
            typeField.layer.borderColor = RED_BORDER_COLOR
            self.softcon!.isValid = false
        }//if empty field, or one where the text specifies a card not in the deck
        else{
            typeField.layer.borderWidth = 0.0
            typeField.layer.cornerRadius = 0.0
            typeField.layer.borderColor = UIColor.clear.cgColor
            self.softcon!.isValid = true
        }//if we have a valid name
        
    }//updateFieldBorder
    
    static func getTypeFromFieldText(_ text: String) -> Subcondition.ConditionType?{
        
        switch text{
        case CardPropertyCell.typeOptions[0]://""
            return Subcondition.ConditionType.undefinedTotal
        case CardPropertyCell.typeOptions[1]:
            return Subcondition.ConditionType.creatureTotal
        case CardPropertyCell.typeOptions[2]:
            return Subcondition.ConditionType.planeswalkerTotal
        case CardPropertyCell.typeOptions[3]:
            return Subcondition.ConditionType.artifactTotal
        case CardPropertyCell.typeOptions[4]:
            return Subcondition.ConditionType.enchantmentTotal
        case CardPropertyCell.typeOptions[5]:
            return Subcondition.ConditionType.instantTotal
        case CardPropertyCell.typeOptions[6]:
            return Subcondition.ConditionType.sorceryTotal
        case CardPropertyCell.typeOptions[7]:
            return Subcondition.ConditionType.supertypeEqualTo
        default:
            return nil
        }//switch

    }//getTypeFromFieldText
    
    //MARK: UIPickerView functions
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var newText: String = ""
        
        switch pickerView{
        case loPicker:
            newText = self.getLoFieldStrings(forHiValue: hiVal)[row]
            
            loVal = Int(newText)!
            loField.text = newText
            
            self.softcon!.numParam2 = loVal
            
        case hiPicker:
            newText = self.getHiFieldStrings(forLoValue: loVal)[row]
            
            hiVal = Int(newText)!
            hiField.text = newText
            
            self.softcon!.numParam3 = hiVal
            
        default://typePicker
            newText = CardPropertyCell.typeOptions[row]
            
            typeField.text = newText
            
            let conType: Subcondition.ConditionType? = CardPropertyCell.getTypeFromFieldText(newText)
            
            self.softcon!.type = conType
            //Special case for supertype legendary
            if newText == CardPropertyCell.typeOptions[7]{
                self.softcon!.stringParam1 = "Legendary"
            }//if legendary
            else{
                self.softcon!.stringParam1 = nil
            }//else
            
            self.updateFieldBorder()
            
        }//switch
        
        self.endEditing(true)
        
    }//didSelectRow
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView{
        case loPicker:
            return self.getLoFieldStrings(forHiValue: hiVal)[row]
        case hiPicker:
            return self.getHiFieldStrings(forLoValue: loVal)[row]
        default://typePicker
            return CardPropertyCell.typeOptions[row]
        }//switch
    }//titleForRow
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case loPicker:
            return self.getLoFieldStrings(forHiValue: hiVal).count
        case hiPicker:
            return self.getHiFieldStrings(forLoValue: loVal).count
        default://typePicker
            return CardPropertyCell.typeOptions.count
        }//switch
    }
    
}//CardPropertyCell
