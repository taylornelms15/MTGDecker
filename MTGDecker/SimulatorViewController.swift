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
    
    private var EPSILON: Double = 0.01
    private static var NUM_REPETITIONS_BASE: Int = 25000
    private static var SUCCESS_SCALING: Double = 1.2
    
    var deck: Deck?
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var simulator: Simulator?
    var currentSuccessRule: SuccessRule?
    var currentMulliganRuleset: MulliganRuleset?
    
    var progressVC: SimulatorProgressViewController?
    
    @IBOutlet var ruleEditTable: RuleEditTableView!
    @IBOutlet var simulateButtonContainer: UIView!
    @IBOutlet var card7PercentLabel: UILabel!
    @IBOutlet var card6PercentLabel: UILabel!
    @IBOutlet var card5PercentLabel: UILabel!
    @IBOutlet var card4PercentLabel: UILabel!
    @IBOutlet var card3PercentLabel: UILabel!
    @IBOutlet var card7SuccessLabel: UILabel!
    @IBOutlet var card6SuccessLabel: UILabel!
    @IBOutlet var card5SuccessLabel: UILabel!
    @IBOutlet var card4SuccessLabel: UILabel!
    @IBOutlet var card3SuccessLabel: UILabel!
    @IBOutlet var card7HeaderLabel: UILabel!
    @IBOutlet var card6HeaderLabel: UILabel!
    @IBOutlet var card5HeaderLabel: UILabel!
    @IBOutlet var card4HeaderLabel: UILabel!
    @IBOutlet var card3HeaderLabel: UILabel!
    
    var percentLabels: [UILabel] = []
    var successLabels: [UILabel] = []
    var headerLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        
        self.simulateButtonContainer.layer.cornerRadius = 8.0
        self.simulateButtonContainer.layer.borderWidth = 3.0
        self.simulateButtonContainer.layer.borderColor = UIColor.black.cgColor
        
        ruleEditTable.dataSource = self
        ruleEditTable.delegate = self
        ruleEditTable.sectionIndexColor = UIColor.lightText
        
        percentLabels = [card7PercentLabel, card6PercentLabel, card5PercentLabel, card4PercentLabel, card3PercentLabel]
        successLabels = [card7SuccessLabel, card6SuccessLabel, card5SuccessLabel, card4SuccessLabel, card3SuccessLabel]
        headerLabels = [card7HeaderLabel, card6HeaderLabel, card5HeaderLabel, card4HeaderLabel, card3HeaderLabel]
        
        for label in percentLabels{
            label.text = ""
            label.alpha = 0.0
        }
        for label in successLabels{
            label.text = ""
            label.alpha = 0.0
        }
        for label in headerLabels{
            label.alpha = 0.0
        }
        
        //Model
        loadModelRules()
        
        //Simulator Notification things
        
        NotificationCenter.default.addObserver(forName: .simulatorStartedNotification , object: nil, queue: nil) { (notification) in
            self.startSimulator()
        }
        NotificationCenter.default.addObserver(forName: .simulatorEndedNotification , object: nil, queue: nil) { (notification) in
            self.endSimulator()
        }
        NotificationCenter.default.addObserver(forName: .simulatorProgressNotification , object: nil, queue: nil) { (notification) in
            self.postProgress(progress: notification.object as! Float)
        }
        
    }//viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        self.loadModelRules()
        
        ruleEditTable.reloadData()
        
    }//viewWillAppear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.portrait
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ruleEditSegue"{
            if sender is KeepRule{
                let rule: KeepRule = sender as! KeepRule
                
                let newVC: RuleEditViewController = segue.destination as! RuleEditViewController
                
                newVC.keep = rule
                
                newVC.deck = self.deck!
                
            }//if editing a keep rule
            if sender is SuccessRule{
                let rule: SuccessRule = sender as! SuccessRule
                
                let newVC: RuleEditViewController = segue.destination as! RuleEditViewController
                
                newVC.success = rule
                
                newVC.deck = self.deck!
                
                
            }//if editing a success rule
            
        }//if about to edit a rule
        
    }//prepareForSegue
    
    fileprivate func loadModelRules() {
        //Model
        
        self.simulator = Simulator(deck: deck!, intoContext: context)
        let activeSuccessRule = self.deck!.activeSuccessRule
        
        if activeSuccessRule == nil{
            self.currentSuccessRule = loadDefaultSuccess()
        }//if no successRule set
        else{
            self.currentSuccessRule = activeSuccessRule
        }//else
        
        
        let rules: MulliganRuleset? = self.deck!.activeMulliganRuleset
        
        if rules == nil{
            self.currentMulliganRuleset = loadDefaultSet()
        }//if
        else{
            self.currentMulliganRuleset = rules
        }//else
    }//loadModelRules
    
    func loadDefaultSet() -> MulliganRuleset{
        let myDelegate: AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let defaultRules: Set<MulliganRuleset> = myDelegate.mulliganDefaults(context)
        let myDefault: MulliganRuleset = defaultRules.first { (ruleSet) -> Bool in
            return ruleSet.name == MulliganRuleset.LAND_DEFAULT_NAME
        }!//find the default
        
        if deck!.mulliganRulesets == nil{
            deck!.mulliganRulesets = Set<MulliganRuleset>([myDefault])
        }//if
        else{
            deck!.mulliganRulesets!.insert(myDefault)
        }//else
        deck!.activeMulliganRuleset = myDefault
        
        do{
            try context.save()
        }catch{
            NSLog("Error setting some default mulligan rule sets! \(error)")
        }//catch
        
        return myDefault
    }//loadDefaultSet
    
    func loadDefaultSuccess()->SuccessRule{
        let myDelegate: AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let defaultRules: Set<SuccessRule> = myDelegate.successDefaults(context)
        let myDefault: SuccessRule = defaultRules.first { (ruleSet) -> Bool in
            return ruleSet.name == SuccessRule.PLAYABLE_DEFAULT_NAME
        }!//find the default
        
        if deck!.successRuleList.isEmpty{
            deck!.successRuleList = Set<SuccessRule>([myDefault])
        }//if
        else{
            deck!.successRuleList.insert(myDefault)
        }
        deck!.activeSuccessRule = myDefault
        
        do{
            try context.save()
        }catch{
            NSLog("Error setting some default mulligan rule sets! \(error)")
        }//catch
        
        return myDefault
        
    }//loadDefaultSuccess
    
    func updateResults(fromResult: SimulationResult){

        UIView.animate(withDuration: 1.0) {
            
            //For each hand-size condition, check if we got more than EPSILON percentage hands. If so, display the labels for that result. Else, make labels disappear
            
            //Keep
            
            if fromResult.card7Percent > self.EPSILON{
                self.card7PercentLabel.text = fromResult.card7String()
                self.card7PercentLabel.alpha = 1.0
                self.card7HeaderLabel.alpha = 1.0
            }
            else{
                self.card7PercentLabel.alpha = 0.0
                self.card7HeaderLabel.alpha = 0.0
            }
            if fromResult.card6Percent > self.EPSILON{
                self.card6PercentLabel.text = fromResult.card6String()
                self.card6PercentLabel.alpha = 1.0
                self.card6HeaderLabel.alpha = 1.0
            }
            else{
                self.card6PercentLabel.alpha = 0.0
                self.card6HeaderLabel.alpha = 0.0
            }
            if fromResult.card5Percent > self.EPSILON{
                self.card5PercentLabel.text = fromResult.card5String()
                self.card5PercentLabel.alpha = 1.0
                self.card5HeaderLabel.alpha = 1.0
            }
            else{
                self.card5PercentLabel.alpha = 0.0
                self.card5HeaderLabel.alpha = 0.0
            }
            if fromResult.card4Percent > self.EPSILON{
                self.card4PercentLabel.text = fromResult.card4String()
                self.card4PercentLabel.alpha = 1.0
                self.card4HeaderLabel.alpha = 1.0
            }
            else{
                self.card4PercentLabel.alpha = 0.0
                self.card4HeaderLabel.alpha = 0.0
            }
            if fromResult.card3Percent > self.EPSILON{
                self.card3PercentLabel.text = fromResult.card3String()
                self.card3PercentLabel.alpha = 1.0
                self.card3HeaderLabel.alpha = 1.0
            }
            else{
                self.card3PercentLabel.alpha = 0.0
                self.card3HeaderLabel.alpha = 0.0
            }
            
            //Success
            
            if fromResult.card7SPercent > self.EPSILON{
                self.card7SuccessLabel.text = fromResult.card7SString()
                self.card7SuccessLabel.alpha = 1.0
            }
            else{
                self.card7SuccessLabel.alpha = 0.0
            }
            if fromResult.card6SPercent > self.EPSILON{
                self.card6SuccessLabel.text = fromResult.card6SString()
                self.card6SuccessLabel.alpha = 1.0
            }
            else{
                self.card6SuccessLabel.alpha = 0.0
            }
            if fromResult.card5SPercent > self.EPSILON{
                self.card5SuccessLabel.text = fromResult.card5SString()
                self.card5SuccessLabel.alpha = 1.0
            }
            else{
                self.card5SuccessLabel.alpha = 0.0
            }
            if fromResult.card4SPercent > self.EPSILON{
                self.card4SuccessLabel.text = fromResult.card4SString()
                self.card4SuccessLabel.alpha = 1.0
            }
            else{
                self.card4SuccessLabel.alpha = 0.0
            }
            if fromResult.card3SPercent > self.EPSILON{
                self.card3SuccessLabel.text = fromResult.card3SString()
                self.card3SuccessLabel.alpha = 1.0
            }
            else{
                self.card3SuccessLabel.alpha = 0.0
            }
            
        }//animate changes
        
        
        
    }//updateResults
    
    
    
    //Simulator Functions
    
    @IBAction func simulateButtonPress(_ sender: UITapGestureRecognizer) {
        DispatchQueue.global(qos: .userInitiated).async {
            //TODO: put the success rule calculations into the ratio equation
            let repetitions: Int = Int(
                Double(SimulatorViewController.NUM_REPETITIONS_BASE)
                * self.currentMulliganRuleset!.performanceRatio
                * ((5.0 * self.currentSuccessRule!.performanceRatio + SimulatorViewController.SUCCESS_SCALING) / 6.0)
            )//repetitions
            let result: SimulationResult = self.simulator!.testDeckAgainstMulliganMultiple(ruleset: self.currentMulliganRuleset!, repetitions: repetitions, success: self.currentSuccessRule!)
            
            DispatchQueue.main.async {
                self.updateResults(fromResult: result)
            }
            
            print("\(result)")
        }//async
    }//simulateButtonPress
    
    ///Handles UI ramifications of starting simulator up
    func startSimulator(){
        let newVC = storyboard!.instantiateViewController(withIdentifier: "SimulatorProgressViewController") as! SimulatorProgressViewController
        newVC.modalPresentationStyle = .overCurrentContext
        
        
        
        
        newVC.loadView()
        
        newVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        newVC.containerView.layer.cornerRadius = 12.0
        newVC.containerView.layer.borderColor = UIColor.black.cgColor
        newVC.containerView.layer.borderWidth = 2.0
        newVC.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        newVC.progressView.setProgress(0.0, animated: false)
        
        newVC.activityIndicator.startAnimating()
        newVC.modalTransitionStyle = .crossDissolve
        
        present(newVC, animated: true, completion: nil)
        
        progressVC = newVC;

    }//startSimulator
    
    ///Handles UI ramifications of ending simulator
    func endSimulator(){
        
        if progressVC != nil{
            progressVC!.activityIndicator.stopAnimating()
            
            self.dismiss(animated: true, completion: nil)
            
            progressVC = nil
        }
        
    }//endSimulator
    
    func postProgress(progress: Float){
        
        DispatchQueue.main.async {
            if self.progressVC != nil{
                self.progressVC!.progressView.setProgress(progress, animated: true)
            }//if we have a progressVC
        }//async
        
    }//postProgress
    
    
    
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
            
            if indexPath.section == 0{
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
                let mySuccessRule: SuccessRule = self.currentSuccessRule!

                ruleCell.softInit(path: indexPath, success: mySuccessRule)
            }//if a successRule
            
            return ruleCell
            
        }//if ruleEditTable
        
        return UITableViewCell()//garbage init
    }//cellForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
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
            
            self.performSegue(withIdentifier: "ruleEditSegue", sender: (myKeepRule))
            
        }//if a keepRule
        else{
            let mySuccessRule: SuccessRule = self.currentSuccessRule!
            
            self.performSegue(withIdentifier: "ruleEditSegue", sender: (mySuccessRule))
            
        }//if a successRule
        
    }//didSelectRowAt
    
    
    
}//SimulatorViewController

extension Notification.Name{
    static let simulatorStartedNotification = Notification.Name(rawValue: "simulatorStarted")
    static let simulatorProgressNotification = Notification.Name(rawValue: "simulatorProgress")
    static let simulatorEndedNotification = Notification.Name(rawValue: "simulatorEnded")
}
