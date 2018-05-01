//
//  PlayableCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/29/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class PlayableCell: ConditionCell, UIPickerViewDelegate, UIPickerViewDataSource{

    
    
    static var typeOption: [String] = ["",
                                        "creature",
                                        "non-land card",
                                        "planeswalker",
                                        "artifact",
                                        "enchantment",
                                        "instant",
                                        "sorcery"
                                        ]//typeOptions

    static var turnOption: [String] = ["with cards in hand",
                                       "by turn 1",
                                       "by turn 2",
                                       "by turn 3",
                                       "by turn 4"
                                        ]//turnOption
    
    @IBOutlet var typeField: UITextField!
    @IBOutlet var turnField: UITextField!
    
    var typePicker: UIPickerView?
    var turnPicker: UIPickerView?
    
    override func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition?) {
        super.softInit(path: path, handSize: handSize, softcon: softcon)
        
        typePicker = UIPickerView()
        turnPicker = UIPickerView()
        
        typePicker!.dataSource = self
        typePicker!.delegate = self
        turnPicker!.dataSource = self
        turnPicker!.delegate = self
        
        typeField.inputView = typePicker!
        turnField.inputView = turnPicker!
        
        if softcon != nil{
            
            //turnField
            if softcon!.type == Subcondition.ConditionType.playable{
                turnField.text = PlayableCell.turnOption[0]
            }//if simply playable
            else{
                switch softcon!.numParam1{
                case 1:
                    turnField.text = PlayableCell.turnOption[1]
                case 2:
                    turnField.text = PlayableCell.turnOption[2]
                case 3:
                    turnField.text = PlayableCell.turnOption[3]
                case 4:
                    turnField.text = PlayableCell.turnOption[4]
                default://if illegal or OOB value, just set it to "playable by turn 1"
                    softcon!.numParam1 = 1
                    turnField.text = PlayableCell.turnOption[1]
                }//switch
            }//if playable by turn
            
            //typeField
            switch softcon!.typeParam!{
            case Subcondition.CardType.creature:
                typeField.text = PlayableCell.typeOption[1]
            case Subcondition.CardType.nonland:
                typeField.text = PlayableCell.typeOption[2]
            case Subcondition.CardType.planeswalker:
                typeField.text = PlayableCell.typeOption[3]
            case Subcondition.CardType.artifact:
                typeField.text = PlayableCell.typeOption[4]
            case Subcondition.CardType.enchantment:
                typeField.text = PlayableCell.typeOption[5]
            case Subcondition.CardType.instant:
                typeField.text = PlayableCell.typeOption[6]
            case Subcondition.CardType.sorcery:
                typeField.text = PlayableCell.typeOption[7]
            default://covers the .none type
                softcon!.typeParam = Subcondition.CardType.none
                typeField.text = PlayableCell.typeOption[0]
            }//typeParam
            
        }//if
        
        self.updateFieldBorder()
        
    }//softInit
    
    /**
     Checks the contents of the text fields. If they are selecting a valid type, the fields have no border, and are good to go. Otherwise, sets the border color to red, to indicate a missing parameter
     */
    func updateFieldBorder(){
        
        if typeField.text == nil || typeField.text == "" || !PlayableCell.typeOption.contains(typeField.text!){
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
    
    
    
    //MARK: UIPickerViewFunctions
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var newText: String = ""
        switch pickerView{
        case typePicker:
            newText = PlayableCell.typeOption[row]
            
            typeField.text = newText
            
            switch newText{

            case PlayableCell.typeOption[1]:
                softcon!.typeParam = Subcondition.CardType.creature
            case PlayableCell.typeOption[2]:
                softcon!.typeParam = Subcondition.CardType.nonland
            case PlayableCell.typeOption[3]:
                softcon!.typeParam = Subcondition.CardType.planeswalker
            case PlayableCell.typeOption[4]:
                softcon!.typeParam = Subcondition.CardType.artifact
            case PlayableCell.typeOption[5]:
                softcon!.typeParam = Subcondition.CardType.enchantment
            case PlayableCell.typeOption[6]:
                softcon!.typeParam = Subcondition.CardType.instant
            case PlayableCell.typeOption[7]:
                softcon!.typeParam = Subcondition.CardType.sorcery
            default://also covers ""
                softcon!.typeParam = Subcondition.CardType.none
                typeField.text = ""
            }//switch
            
            self.updateFieldBorder()
            
        default://turnPicker
            newText = PlayableCell.turnOption[row]
            
            turnField.text = newText
            
            switch newText{
            case PlayableCell.turnOption[1]:
                softcon!.type = Subcondition.ConditionType.playableByTurn
                softcon!.numParam1 = 1
            case PlayableCell.turnOption[2]:
                softcon!.type = Subcondition.ConditionType.playableByTurn
                softcon!.numParam1 = 2
            case PlayableCell.turnOption[3]:
                softcon!.type = Subcondition.ConditionType.playableByTurn
                softcon!.numParam1 = 3
            case PlayableCell.turnOption[4]:
                softcon!.type = Subcondition.ConditionType.playableByTurn
                softcon!.numParam1 = 4
            default://covers "any turn" option
                softcon!.type = Subcondition.ConditionType.playable
                softcon!.numParam1 = nil
            }//switch
            
        }//switch
        
        
        self.endEditing(true)
    }//didSelectRow
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }//numberOfComponents
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView{
        case typePicker:
            return PlayableCell.typeOption[row]
        default://turnPicker
            return PlayableCell.turnOption[row]
        }//switch
    }//titleForRow
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case typePicker:
            return PlayableCell.typeOption.count
        default://turnPicker
            return PlayableCell.turnOption.count
        }//switch
    }//numberOfRowsInComponent

    
}//PlayableCell
