//
//  SpecificCardCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/29/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

var RED_BORDER_COLOR: CGColor = UIColor.red.cgColor
var RED_BORDER_WIDTH: CGFloat = 2.0
var RED_BORDER_CURVE: CGFloat = 5.0

class SpecificCardCell: ConditionCell, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate{

    
    @IBOutlet var specificField: UITextField!
    var picker: UIPickerView?
    
    var cardNames: [String] = []
    
    override func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition? = nil){
        super.softInit(path: path, handSize: handSize, softcon: softcon)
        
        self.picker = UIPickerView()
        
        self.picker!.delegate = self
        self.picker!.dataSource = self
        
        specificField.inputView = self.picker!
        specificField.delegate = self
        
        if let cardName = (softcon == nil ? nil : softcon!.stringParam1){
            if cardName != "" && cardNames.contains(cardName){
                specificField.text = cardName
            }//if
            else{
                specificField.text = ""
            }//else
        }//if
        else{
            specificField.text = ""
        }//else
        
        updateFieldBorder()
        
    }//softInit
    
    /**
        Sets the choices for card names in the deck.
     
        MUST be called before softInit
     
     - parameter deck: A deck from which to draw possible card name choices
     */
    func setCardNameChoices(deck: Deck){
        
        let sortedCards: [[(MCard, Int)]] = deck.getCardsSorted()
        let sortedNames = SpecificCardCell.sortNames(cardArray: sortedCards)
        
        self.cardNames = sortedNames
        
    }//setCardNameChoices
    
    static func sortNames(cardArray: [[(MCard, Int)]]) -> [String]{
        var result: [String] = []
        for typeArray in cardArray{
            let tempArray: [(MCard, Int)] = typeArray.sorted { (lhs, rhs) -> Bool in
                if lhs.1 < rhs.1{
                    return true
                }
                if lhs.1 > rhs.1{
                    return false
                }
                return lhs.0 < rhs.0
            }//sort by quantity, then by name and other factors
            
            for cardTuple in tempArray{
                result.append(cardTuple.0.name)
            }//for each card tuple in our newly-sorted array
        }//for each outer array (each type)

        return result
    }//sortNames
    
    /**
     Checks the contents of the text field. If they are selecting a valid card name, the field has no border, and is good to go. Otherwise, sets the border color to red, to indicate a missing parameter
     */
    func updateFieldBorder(){
        
        if specificField.text == nil || specificField.text == "" || !cardNames.contains(specificField.text!){
            specificField.layer.borderWidth = RED_BORDER_WIDTH
            specificField.layer.cornerRadius = RED_BORDER_CURVE
            specificField.layer.borderColor = RED_BORDER_COLOR
            self.softcon!.isValid = false
        }//if empty field, or one where the text specifies a card not in the deck
        else{
            specificField.layer.borderWidth = 0.0
            specificField.layer.cornerRadius = 0.0
            specificField.layer.borderColor = UIColor.clear.cgColor
            self.softcon!.isValid = true
        }//if we have a valid name
        
    }//updateFieldBorder
    
    
    //MARK: UIPickerView functions
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var nameText: String = ""
        if row != 0{
            nameText = cardNames[row - 1]
        }//if we chose something
        
        specificField.text = nameText
        
        softcon!.stringParam1 = nameText
        
        self.endEditing(true)
        
        self.updateFieldBorder()
        
    }//didSelectRow
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == specificField{
            if let rowNum = cardNames.index(of: textField.text ?? ""){
                picker!.selectRow(rowNum + 1, inComponent: 0, animated: false)
            }//if we already had a card in there, jump to that card name
        }//if the specificField
    }//textFieldDidBeginEditing
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return ""
        }//if
        return cardNames[row - 1]
    }//titleForRow
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }//numberOfComponents
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cardNames.count + 1
    }//numberOfRowsInComponent
    
    
}//SpecificCardCell
