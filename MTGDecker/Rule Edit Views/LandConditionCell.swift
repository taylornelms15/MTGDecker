//
//  LandConditionCell.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/26/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit

class LandConditionCell: ConditionCell, UIPickerViewDelegate, UIPickerViewDataSource{

    
    
    @IBOutlet var loField: UITextField!
    @IBOutlet var hiField: UITextField!
    
    private var loVal: Int = 0
    private var hiVal: Int = 7
    
    var loPicker: UIPickerView?
    var hiPicker: UIPickerView?
    

    
    override func softInit(path: IndexPath, handSize: Int16, softcon: Softcondition? = nil) {
        super.softInit(path: path, handSize: handSize, softcon: softcon)
        
        setLoHiFromSoftcon(softcon)
        
        loPicker = UIPickerView()
        hiPicker = UIPickerView()
        
        loPicker!.dataSource = self
        loPicker!.delegate = self
        hiPicker!.dataSource = self
        hiPicker!.delegate = self
        
        
        loField.inputView = loPicker
        hiField.inputView = hiPicker
        
        
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == loPicker{
            let possibleStrings = self.getLoFieldStrings(forHiValue: hiVal)
            loVal = Int(possibleStrings[row])!
            if self.softcon != nil{
                self.softcon!.numParam2 = loVal
            }
            
            loField.text = possibleStrings[row]
            
        }//loPicker
        else{
            let possibleStrings = self.getHiFieldStrings(forLoValue: loVal)
            hiVal = Int(possibleStrings[row])!
            if self.softcon != nil{
                self.softcon!.numParam3 = hiVal
            }
            
            hiField.text = possibleStrings[row]
            
        }//hiPicker
        
        endEditing(true)
        
    }//didSelectRow
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }//numberOfComponents
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == loPicker{
            return self.getLoFieldStrings(forHiValue: hiVal).count
        }//if lo picker
        else{
            return self.getHiFieldStrings(forLoValue: loVal).count
        }//if hi picker
    }//numberOfRowsInComponent
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == loPicker{
            return self.getLoFieldStrings(forHiValue: hiVal)[row]
        }
        else{
            return self.getHiFieldStrings(forLoValue: loVal)[row]
        }
        
    }//titleForRow
    

    
}//LandConditionCell
