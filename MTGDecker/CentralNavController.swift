//
//  CentralNavController.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/25/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CentralNavController: UINavigationController, UINavigationControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

    }//viewDidLoad
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if viewController.isKind(of: DeckSelectViewController.self){
            (viewController as! DeckSelectViewController).viewWillAppear(true)
        }//if DeckSelectViewController
        
        if viewController.isKind(of: DeckDetailViewController.self){
            (viewController as! DeckDetailViewController).viewWillAppear(true)
        }
        
    }//willShowViewController

    

    
}//CentralNavController
