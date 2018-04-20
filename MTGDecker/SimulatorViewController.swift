//
//  SimulatorViewController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/15/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SimulatorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var deck: Deck?
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var simulator: Simulator?
    var currentSuccessRule: SuccessRule?
    var currentMulliganRuleset: MulliganRuleset?
    
    @IBOutlet var ruleEditTable: RuleEditTableView!
    @IBOutlet var simulateButtonContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.simulateButtonContainer.layer.cornerRadius = 8.0
        self.simulateButtonContainer.layer.borderWidth = 3.0
        self.simulateButtonContainer.layer.borderColor = UIColor.black.cgColor
        
        ruleEditTable.dataSource = self
        ruleEditTable.delegate = self
        ruleEditTable.sectionIndexColor = UIColor.lightText
        
        self.simulator = Simulator(deck: deck!)
        self.currentSuccessRule = self.deck!.activeSuccessRule
        let rules: MulliganRuleset? = self.deck!.inv_player!.activeMulliganRuleset
        if rules == nil{
            self.currentMulliganRuleset = loadDefaultSet()
        }
        else{
            self.currentMulliganRuleset = rules
        }
        
    }//viewDidLoad
    
    func loadDefaultSet() -> MulliganRuleset{
        let myDelegate: AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let defaultRules: Set<MulliganRuleset> = myDelegate.mulliganDefaults(context)
        let landDefault: MulliganRuleset = defaultRules.first { (ruleSet) -> Bool in
            return ruleSet.name == MulliganRuleset.LAND_DEFAULT_NAME
        }!//find the default
        
        deck!.inv_player!.mulliganRulesetList?.insert(landDefault)
        deck!.inv_player!.activeMulliganRuleset = landDefault
        
        do{
            try context.save()
        }catch{
            NSLog("Error setting some default mulligan rule sets! \(error)")
        }//catch
        
        return landDefault
    }//loadDefaultSet
    
    
    
    
    
    @IBAction func simulateButtonPress(_ sender: UITapGestureRecognizer) {
        print("Button Pressed!")
        
    }//simulateButtonPress
    
    
    
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName: String = RuleEditTableView.sectionTitles[section]
        
        let headerView: UILabel = UILabel()
        headerView.text = sectionName
        headerView.font = UIFont.preferredFont(forTextStyle: .headline)
        headerView.textColor = UIColor.lightText

        return headerView
        
    }//viewForHeaderInSection
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }//heightForHeaderInSection
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == ruleEditTable{
            return 2
        }//if ruleEditTable
        
        return 0
    }//number of sections
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ruleEditTable{
            if section == 0{
                return 4
            }//if mulligan rules section
            else{
                return 1
            }//if success rules section
        }//if ruleEditTable
        return 0
    }//numberOfRowsInSection
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ruleEditTable{
            let ruleCell: RuleSummaryCell = tableView.dequeueReusableCell(withIdentifier: "ruleCell") as! RuleSummaryCell
            
            if indexPath.section == 0{//TODO: screw around with real rules
                var myKeepRule: KeepRule?
                switch indexPath.row{
                case 0:
                    myKeepRule = currentMulliganRuleset!.keepRule7
                case 1:
                    myKeepRule = currentMulliganRuleset!.keepRule6
                case 2:
                    myKeepRule = currentMulliganRuleset!.keepRule5
                default:
                    myKeepRule = currentMulliganRuleset!.keepRule4
                }
                ruleCell.softInit(path: indexPath, keep: myKeepRule!)
            }//if a keepRule
            else{
                let mySuccessRule = SuccessRule(entity: SuccessRule.entityDescription(context: context), insertInto: context)
                ruleCell.softInit(path: indexPath, success: mySuccessRule)
            }//if a successRule
            
            return ruleCell
            
        }//if ruleEditTable
        
        return UITableViewCell()//garbage init
    }//cellForRowAtIndexPath
    
    
    
}//SimulatorViewController
